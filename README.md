# WASM Demo App

This Rails application is intended to serve as a demo app for joyofrails.com. It is designed to compile to WebAssembly so that it can be loaded directly in the browser.

## Building the WASM version

These steps are adapted from https://github.com/palkan/turbo-music-drive/compare/main...spike/wasmify

The minimal WASM version of the app can be built as follows:

- Install [wasi-vfs](https://github.com/kateinoigakukun/wasi-vfs):

  ```sh
  brew tap kateinoigakukun/wasi-vfs https://github.com/kateinoigakukun/wasi-vfs.git
  brew install kateinoigakukun/wasi-vfs/wasi-vfs
  ```

- Install Rust toolchain:

  ```sh
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```

- Build a WASM module with Ruby and all the app's dependencies (from the project's root):

  ```sh
  bin/rbwasm build --ruby-version 3.3 -o .wasm/ruby.wasm
  ```

Now you should be able to run a test script (performing an HTTP/Rack request) using [wasmtime](https://github.com/bytecodealliance/wasmtime) like this (from the project's root):

```sh
wasmtime run --dir ./::/ .wasm/ruby.wasm -e "$(cat .wasm/test.rb)"
```

## Packaging

To pack the whole app into a single `.wasm` module (and avoid mounting files), you can use `wasi-vfs`:

```sh
bin/rbwasm pack .wasm/ruby.wasm \
  --dir ./app::/app \
  --dir ./config::/config \
  --dir ./db::/db \
  --dir ./vendor::/vendor \
  --dir ./public::/public \
  --dir ./lib::/lib \
  -o .wasm/rails.wasm
```

You can now verify it as follows:

```sh
wasmtime run .wasm/rails.wasm -e "$(cat .wasm/test.rb)"
```

### Web version

To run the app in the browser, we must compile it with the `js` gem included. For that, run the following commands:

```sh
JS=true bin/rbwasm build --ruby-version 3.3 -o .wasm/ruby-web.wasm
```

And now pack the app:

```sh
bin/rbwasm pack .wasm/ruby-web.wasm \
  --dir ./app::/app \
  --dir ./config::/config \
  --dir ./db::/db \
  --dir ./vendor::/vendor \
  --dir ./public::/public \
  --dir ./lib::/lib \
  -o .wasm/rails-web.wasm
```
