# lib

This Nix module provides a collection of utility functions and common configurations used across various parts of the system.  It aims to centralize reusable logic, making configurations more modular and maintainable. The functions cover areas such as string manipulation, list processing, attribute set merging, and common system settings. This module serves as a building block for other Nix configurations, promoting consistency and reducing redundancy.

## Options

### `lib.concatMapStrings`

*   **Type:** `(a -> list string) -> list a -> string`
*   **Default:**  `(f: xs: builtins.concatStringsSep "" (builtins.map f xs))`

**Description:** This function takes a function `f` and a list `xs` as input. It applies the function `f` to each element of the list `xs`, resulting in a list of strings. Finally, it concatenates all the strings in the resulting list into a single string, using an empty string as a separator.  This is functionally equivalent to `builtins.concatStringsSep "" (builtins.map f xs)` but provided as a convenience.

**Example:**

```nix
let
  myList = [ 1 2 3 ];
  stringify = x: toString x;
  concatenated = lib.concatMapStrings stringify myList;
in
concatenated # "123"
```

### `lib.mdnsHostname`

*   **Type:** `string -> string`
*   **Default:** `(hostname: "${hostname}.local")`

**Description:** This function takes a hostname as input and returns the corresponding mDNS (multicast DNS) hostname by appending ".local" to the input hostname. This is useful for resolving hostnames within a local network without the need for a central DNS server.

**Example:**

```nix
let
  myHostname = "mycomputer";
  mdnsAddress = lib.mdnsHostname myHostname;
in
mdnsAddress # "mycomputer.local"
```

### `lib.mkAfter`

*   **Type:** `a -> a -> a`
*   **Default:** `(before: after: before // after)`

**Description:** This function takes two attribute sets, `before` and `after`, and merges them into a single attribute set. If the same attribute exists in both `before` and `after`, the value from `after` takes precedence.  This allows you to override default configurations specified in `before` with values from `after`.  It essentially provides a way to apply configurations "after" another configuration. It's an alias to the `//` operator.

**Example:**

```nix
let
  defaults = { setting1 = "default"; setting2 = 123; };
  overrides = { setting1 = "override"; };
  merged = lib.mkAfter defaults overrides;
in
merged # { setting1 = "override"; setting2 = 123; }
```

### `lib.mkBefore`

*   **Type:** `a -> a -> a`
*   **Default:** `(after: before: before // after)`

**Description:**  This function takes two attribute sets, `after` and `before`, and merges them into a single attribute set. If the same attribute exists in both `after` and `before`, the value from `before` takes precedence. This effectively allows defining configurations "before" other configurations, letting the "after" config win. Useful for setting up sane defaults when you want modules to be able to easily override values.  It's similar to `mkAfter`, but with the order of arguments reversed.

**Example:**

```nix
let
  defaults = { setting1 = "default"; setting2 = 123; };
  overrides = { setting1 = "override"; };
  merged = lib.mkBefore overrides defaults;
in
merged # { setting1 = "override"; setting2 = 123; }
```

### `lib.myOption`

*   **Type:** `string -> string`
*   **Default:** `(name: "Hello, " + name + "!")`

**Description:** This function demonstrates a simple example. It takes a name as input and returns a greeting string, which includes the input name. This is a placeholder function that could be replaced with more complex logic. It serves as a simple example for understanding the function's input and output.

**Example:**

```nix
let
  greeting = lib.myOption "World";
in
greeting # "Hello, World!"
```

### `lib.toEnum`

*   **Type:** `string -> list string -> string`
*   **Default:** `(value: values:
    if builtins.elem value values then
      value
    else
      throw "Invalid value '" + value + "', expected one of: " + builtins.toString values)`

**Description:** This function takes a `value` (a string) and a list of valid string `values` (also a string) as input.  It checks if the `value` is present in the `values` list.  If it is, the function returns the original `value`.  If it is not, the function throws an error message indicating the invalid value and listing the expected values.  This is useful for enforcing constraints on string-based configuration options, ensuring that only allowed values are used.  It effectively provides type-safe enum-like behavior.

**Example:**

```nix
let
  validValues = [ "option1" "option2" "option3" ];
  validValue = lib.toEnum "option2" validValues;
  invalidValue = lib.toEnum "invalid" validValues; # throws an error
in
validValue # "option2"
```

### `lib.capitalize`

*   **Type:** `string -> string`
*   **Default:** `(s: builtins.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (builtins.stringLength s - 1) s)`

**Description:** This function takes a string `s` as input and returns a new string with the first letter capitalized. It uses `builtins.toUpper` to convert the first character to uppercase and concatenates it with the rest of the string, which remains unchanged.

**Example:**

```nix
let
  uncapitalized = "hello";
  capitalized = lib.capitalize uncapitalized;
in
capitalized # "Hello"
```
