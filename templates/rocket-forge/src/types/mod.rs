//! Custom type definitions and HTTP request/response handling.
//!
//! This module provides specialized types for handling file streaming,
//! HTTP range requests, and other custom data structures used throughout
//! the application.

use rocket::{
    http::Status,
    outcome::Outcome,
    request::{self, FromRequest},
    response::Responder,
    Request, Response,
};
use std::{
    fs::File,
    io::{self, prelude::*, Cursor, SeekFrom},
    sync::Mutex,
};

/// A file that can be streamed with HTTP range request support.
///
/// This type handles both full file downloads and partial content requests
/// (HTTP 206 responses) for efficient media streaming. It automatically
/// determines the MIME type based on the file extension.
///
/// # Features
///
/// - Support for HTTP range requests (partial content)
/// - Automatic MIME type detection
/// - Thread-safe file access with mutex protection
/// - Efficient streaming for large files
pub struct StreamedFile {
    file: Mutex<File>,
    size: u64,
    range: Option<std::ops::Range<u64>>,
    content_type: String,
}

impl StreamedFile {
    /// Creates a new `StreamedFile` from a file path.
    ///
    /// # Arguments
    ///
    /// * `path` - Path to the file to stream
    /// * `range` - Optional byte range for partial content requests
    ///
    /// # Returns
    ///
    /// Returns a `StreamedFile` instance or an IO error if the file cannot be opened.
    ///
    /// # Examples
    ///
    /// ```ignore
    /// use app::types::StreamedFile;
    ///
    /// // Full file
    /// let file = StreamedFile::new("/path/to/video.mp4", None)?;
    ///
    /// // Partial content (bytes 1000-2000)
    /// let file = StreamedFile::new("/path/to/video.mp4", Some(1000..2001))?;
    /// # Ok::<(), std::io::Error>(())
    /// ```
    pub fn new(path: &str, range: Option<std::ops::Range<u64>>) -> io::Result<Self> {
        let file = File::open(path)?;
        let size = file.metadata()?.len();
        let content_type = mime_guess::from_path(path)
            .first_or_octet_stream()
            .to_string();
        Ok(Self {
            file: Mutex::new(file),
            content_type,
            size,
            range,
        })
    }
}
impl<'r> Responder<'r, 'static> for StreamedFile {
    /// Responds with file content, supporting both full and partial content requests.
    ///
    /// This implementation handles:
    /// - Full file downloads (HTTP 200)
    /// - Partial content requests (HTTP 206)
    /// - Proper HTTP headers for range requests
    /// - MIME type detection and Content-Type headers
    ///
    /// # Returns
    ///
    /// Returns a Rocket response with appropriate status code and headers.
    fn respond_to(self, _req: &'r Request<'_>) -> rocket::response::Result<'static> {
        let mut response = Response::build();
        response.raw_header("Accept-Ranges", "bytes");
        response.raw_header("Content-Type", self.content_type);
        response.raw_header("Content-Length", self.size.to_string());

        // Handle partial content
        if let Some(mut range) = self.range {
            let mut file = self.file.lock().unwrap();

            // Correct open-ended ranges based on the file size.
            if range.start >= self.size {
                return Err(Status::RangeNotSatisfiable);
            }
            if range.end > self.size {
                range.end = self.size;
            }
            let length = range.end - range.start;

            // Seek to the starting position and read the bytes.
            file.seek(SeekFrom::Start(range.start)).unwrap();
            let mut buf = vec![0u8; length as usize];
            let bytes_read = file.read(&mut buf).unwrap();

            // Build the response with the partial content.
            response
                .status(Status::PartialContent)
                .raw_header(
                    "Content-Range",
                    format!("bytes {}-{}/{}", range.start, range.end - 1, self.size),
                )
                .raw_header("Content-Length", length.to_string())
                .sized_body(bytes_read, io::Cursor::new(buf));
        } else {
            // Handle full content (no range header)
            let mut file = self.file.lock().unwrap();
            let mut buf = Vec::new();
            file.read_to_end(&mut buf).unwrap();
            response
                .status(Status::Ok)
                .sized_body(self.size as usize, Cursor::new(buf));
        }

        response.ok()
    }
}
/// HTTP Range request wrapper for extracting byte ranges from requests.
///
/// This type implements Rocket's `FromRequest` trait to automatically
/// parse HTTP Range headers and extract the requested byte range.
///
/// Supports various range formats:
/// - `bytes=start-end` - Specific byte range
/// - `bytes=start-` - From start to end of file
/// - `bytes=-suffix` - Last N bytes of file
///
/// # Examples
///
/// ```ignore
/// use rocket::get;
/// use app::types::HttpRange;
///
/// #[get("/video/<id>")]
/// async fn stream_video(id: u32, range: Option<HttpRange>) -> Result<StreamedFile, Status> {
///     let file_path = format!("/videos/{}.mp4", id);
///     let byte_range = range.map(|r| r.0);
///     StreamedFile::new(&file_path, byte_range)
///         .map_err(|_| Status::NotFound)
/// }
/// ```
pub struct HttpRange(pub std::ops::Range<u64>);

#[rocket::async_trait]
impl<'r> FromRequest<'r> for HttpRange {
    type Error = ();
    
    /// Extracts HTTP Range header and parses it into a byte range.
    ///
    /// Parses various range formats and validates the range values.
    /// Returns `Outcome::Forward` if no Range header is present,
    /// allowing other handlers to process the request.
    ///
    /// # Returns
    ///
    /// - `Success(HttpRange)` - Valid range header parsed
    /// - `Forward(Status::Ok)` - No range header present
    /// - `Error(Status::RangeNotSatisfiable)` - Invalid range format
    async fn from_request(req: &'r Request<'_>) -> request::Outcome<Self, Self::Error> {
        if let Some(range_header) = req.headers().get_one("Range") {
            let range_str = range_header.trim_start_matches("bytes=");
            let parts: Vec<&str> = range_str.split('-').collect();

            let start = parts[0].parse::<u64>().ok();
            let end = parts.get(1).and_then(|s| s.parse::<u64>().ok());

            match (start, end) {
                // Case 1: `Range: bytes=start-end`
                (Some(start), Some(end)) => {
                    // Basic validation - start should be less than end
                    if start > end {
                        Outcome::Error((Status::RangeNotSatisfiable, ()))
                    } else {
                        // The `Range` struct is exclusive of the end value, so we add 1
                        Outcome::Success(HttpRange(start..end + 1))
                    }
                }
                // Case 2: `Range: bytes=start-` (open-ended range)
                (Some(start), None) => {
                    // Use u64::MAX to indicate open-ended range, will be corrected in video handler
                    Outcome::Success(HttpRange(start..u64::MAX))
                }
                // Case 3: `Range: bytes=-suffix` (suffix-byte-range-spec)
                (None, Some(suffix)) => {
                    // Use u64::MAX for start to indicate suffix range, will be corrected in video handler
                    Outcome::Success(HttpRange(u64::MAX..suffix))
                }
                // Case 4: Invalid format
                _ => Outcome::Error((Status::RangeNotSatisfiable, ())),
            }
        } else {
            // No Range header, so this is a request for the entire file.
            // We return `Outcome::Forward` to let a different handler deal with it.
            Outcome::Forward(Status::Ok)
        }
    }
}
