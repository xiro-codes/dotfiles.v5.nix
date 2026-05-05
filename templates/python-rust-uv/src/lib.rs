use pyo3::prelude::*;

#[pyfunction]
fn hello_from_rust() -> String {
    "Hello from Rust! 🦀".to_string()
}

#[pymodule]
fn core(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(hello_from_rust, m)?)?;
    Ok(())
}
