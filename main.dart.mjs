// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(
      await _compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

let _isCompileStreamingSupported;
async function _compileStreaming(source, builtins) {
  _isCompileStreamingSupported ??= WebAssembly.compileStreaming(
    new Response(
      new Uint8Array([0,97,115,109,1,0,0,0,1,4,1,96,0,0,2,23,1,14,119,97,115,109,58,106,115,45,115,116,114,105,110,103,4,99,97,115,116,0,0]),
      {headers: {'Content-Type': 'application/wasm'}},
    ),
    builtins,
  ).then(() => false, (e) => e instanceof WebAssembly.CompileError);
  if (await _isCompileStreamingSupported) {
    return WebAssembly.compileStreaming(source, builtins);
  }
  return WebAssembly.compile(await (await source).arrayBuffer(), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: (decoder, codeUnits) => decoder.decode(codeUnits),
      AC: Function.prototype.call.bind(DataView.prototype.getFloat64),
      AD: x0 => x0.hash,
      AE: (o, c) => o instanceof c,
      AF: (x0,x1) => { x0.noValidate = x1 },
      AG: x0 => x0.computedStyleMap(),
      AH: x0 => x0.firstChild,
      AI: (x0,x1) => { x0.disabled = x1 },
      AJ: (x0,x1) => x0.selectNode(x1),
      AK: () => globalThis._flutter,
      B: s => printToConsole(s),
      BB: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      BC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      BD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      BE: x0 => x0.vendor,
      BF: x0 => x0.isConnected,
      BG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      BH: x0 => x0.viewConstraints,
      BI: (x0,x1) => { x0.scrollLeft = x1 },
      BJ: x0 => x0.getSelection(),
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: () => new TextDecoder("utf-8", {fatal: true}),
      CC: Function.prototype.call.bind(DataView.prototype.setFloat64),
      CD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      CE: (x0,x1) => x0.createTextNode(x1),
      CF: x0 => x0.click(),
      CG: x0 => x0.matches,
      CH: x0 => x0.hostElement,
      CI: (x0,x1) => { x0.spellcheck = x1 },
      CJ: x0 => x0.removeAllRanges(),
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: () => new TextDecoder("utf-8", {fatal: false}),
      DC: (t, s) => t.set(s),
      DD: x0 => x0.state,
      DE: (x0,x1) => { x0.nonce = x1 },
      DF: (x0,x1) => x0.getElementsByClassName(x1),
      DG: (x0,x1) => x0.matchMedia(x1),
      DH: x0 => ({runApp: x0}),
      DI: (x0,x1) => { x0.disabled = x1 },
      DJ: (x0,x1) => x0.addRange(x1),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: s => s.trimLeft(),
      EC: Function.prototype.call.bind(DataView.prototype.setFloat32),
      ED: (x0,x1,x2) => x0.addEventListener(x1,x2),
      EE: x0 => x0.nonce,
      EF: (x0,x1) => x0.contains(x1),
      EG: x0 => x0.matches,
      EH: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      EI: (a, i) => a.splice(i, 1),
      EJ: () => globalThis.window,
      F: o => String(o),
      FB: (l, r) => l === r,
      FC: Function.prototype.call.bind(DataView.prototype.getFloat32),
      FD: (x0,x1) => x0.go(x1),
      FE: () => globalThis.window.flutterConfiguration,
      FF: (s) => +s,
      FG: x0 => x0.timeStamp,
      FH: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      FI: a => a.pop(),
      FJ: (x0,x1) => { x0.innerText = x1 },
      G: () => new Error().stack,
      GB: (x0,x1) => x0[x1],
      GC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      GD: (x0,x1) => x0.append(x1),
      GE: (x0,x1) => x0.attachShadow(x1),
      GF: x0 => x0.target,
      GG: (x0,x1) => x0.hasAttribute(x1),
      GH: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      GI: x0 => new WeakRef(x0),
      GJ: x0 => x0.offsetY,
      H: s => JSON.stringify(s),
      HB: x0 => x0.index,
      HC: Function.prototype.call.bind(DataView.prototype.getUint32),
      HD: (x0,x1) => { x0.textContent = x1 },
      HE: x0 => x0.preventDefault(),
      HF: (x0,x1) => x0.dispatchEvent(x1),
      HG: x0 => x0.type,
      HH: () => typeof dartUseDateNowForTicks !== "undefined",
      HI: x0 => x0.deref(),
      HJ: x0 => x0.offsetX,
      I: Function.prototype.call.bind(Number.prototype.toString),
      IB: (o, p, r) => o.replace(p, () => r),
      IC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      ID: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      IE: (x0,x1) => x0.contains(x1),
      IF: (x0,x1) => x0.createEvent(x1),
      IG: (x0,x1) => x0.getModifierState(x1),
      IH: () => Date.now(),
      II: () => globalThis.WeakRef,
      IJ: x0 => x0.button,
      J: Function.prototype.call.bind(String.prototype.indexOf),
      JB: s => s.toUpperCase(),
      JC: Function.prototype.call.bind(DataView.prototype.getInt32),
      JD: x0 => x0.parentElement,
      JE: (x0,x1) => x0.focus(x1),
      JF: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      JG: x0 => x0.buttons,
      JH: () => 1000 * performance.now(),
      JI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      JJ: x0 => x0.classList,
      K: (s, p, i) => s.lastIndexOf(p, i),
      KB: Object.is,
      KC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      KD: (x0,x1) => x0.querySelectorAll(x1),
      KE: (x0,x1) => x0.closest(x1),
      KF: x0 => x0.readText(),
      KG: x0 => x0.ctrlKey,
      KH: (x0,x1) => x0.decode(x1),
      KI: (a, s, e) => a.slice(s, e),
      KJ: (x0,x1) => { x0.height = x1 },
      L: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      LB: (x0,x1) => x0.test(x1),
      LC: Function.prototype.call.bind(DataView.prototype.getUint16),
      LD: x0 => x0.length,
      LE: (x0,x1) => x0.getAttribute(x1),
      LF: x0 => x0.clipboard,
      LG: x0 => x0.getBoundingClientRect(),
      LH: (x0,x1,x2) => x0.slice(x1,x2),
      LI: x0 => x0.close(),
      LJ: (x0,x1) => { x0.width = x1 },
      M: o => o === undefined,
      MB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      MC: o => o instanceof Uint16Array,
      MD: (x0,x1) => x0.item(x1),
      ME: x0 => x0.activeElement,
      MF: (x0,x1) => x0.writeText(x1),
      MG: x0 => x0.y,
      MH: x0 => new Uint8Array(x0),
      MI: x0 => x0.height,
      MJ: x0 => x0.style,
      N: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      NB: Function.prototype.call.bind(String.prototype.toLowerCase),
      NC: Function.prototype.call.bind(DataView.prototype.getInt16),
      ND: x0 => x0.userAgent,
      NE: (x0,x1) => x0.add(x1),
      NF: x0 => x0.unlock(),
      NG: x0 => x0.x,
      NH: (x0,x1) => x0.adoptText(x1),
      NI: x0 => x0.width,
      NJ: x0 => x0.sheet,
      O: (x0,x1) => x0.didCreateEngineInitializer(x1),
      OB: (o, p, r) => o.replaceAll(p, () => r),
      OC: o => o instanceof Int16Array,
      OD: x0 => x0.maxTouchPoints,
      OE: x0 => x0.classList,
      OF: (x0,x1) => x0.lock(x1),
      OG: x0 => x0.top,
      OH: x0 => x0.first(),
      OI: (x0,x1,x2,x3,x4,x5) => x0.createImageBitmap(x1,x2,x3,x4,x5),
      OJ: x0 => x0.head,
      P: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      PB: x0 => x0.flags,
      PC: o => o instanceof Uint8ClampedArray,
      PD: x0 => x0.platform,
      PE: x0 => x0.data,
      PF: x0 => x0.orientation,
      PG: x0 => x0.left,
      PH: x0 => x0.next(),
      PI: (x0,x1) => x0.createImageBitmap(x1),
      PJ: () => globalThis.document,
      Q: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      QB: s => s.trim(),
      QC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      QD: x0 => x0.navigator,
      QE: x0 => x0.scrollTop,
      QF: (x0,x1) => x0.querySelector(x1),
      QG: x0 => x0.offsetTop,
      QH: x0 => x0.current(),
      QI: x0 => new Blob(x0),
      QJ: (x0,x1) => x0.getItem(x1),
      R: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      RB: (a, s) => a.join(s),
      RC: Function.prototype.call.bind(DataView.prototype.setInt32),
      RD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      RE: (handle) => clearTimeout(handle),
      RF: (x0,x1) => { x0.content = x1 },
      RG: x0 => x0.scrollLeft,
      RH: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      RI: x0 => x0.close(),
      RJ: (x0,x1) => x0.key(x1),
      S: x0 => new Promise(x0),
      SB: x0 => x0.random(),
      SC: Function.prototype.call.bind(DataView.prototype.setUint32),
      SD: Date.now,
      SE: (x0,x1) => x0.removeAttribute(x1),
      SF: x0 => x0.head,
      SG: x0 => x0.offsetLeft,
      SH: x0 => x0.v8BreakIterator,
      SI: x0 => x0.naturalHeight,
      SJ: x0 => x0.length,
      T: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      TB: () => globalThis.Math,
      TC: Function.prototype.call.bind(DataView.prototype.setInt16),
      TD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      TE: (x0,x1) => { x0.tabIndex = x1 },
      TF: (x0,x1) => { x0.name = x1 },
      TG: x0 => x0.offsetParent,
      TH: () => globalThis.Intl,
      TI: x0 => x0.naturalWidth,
      TJ: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => x0.drawImage(x1,x2,x3,x4,x5,x6,x7,x8,x9),
      U: (x0,x1,x2) => x0.call(x1,x2),
      UB: (x0,x1) => x0.error(x1),
      UC: Function.prototype.call.bind(DataView.prototype.setUint16),
      UD: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      UE: (x0,x1) => { x0.value = x1 },
      UF: (x0,x1) => { x0.title = x1 },
      UG: x0 => x0.offsetY,
      UH: (x0,x1) => x0.segment(x1),
      UI: (x0,x1) => { x0.src = x1 },
      UJ: (x0,x1) => x0.getContext(x1),
      V: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      VB: () => globalThis.console,
      VC: Function.prototype.call.bind(DataView.prototype.setUint8),
      VD: x0 => x0.style,
      VE: (x0,x1) => { x0.value = x1 },
      VF: () => globalThis.document,
      VG: x0 => x0.offsetX,
      VH: x0 => x0.index,
      VI: x0 => x0.displayHeight,
      VJ: (x0,x1) => { x0.height = x1 },
      W: x0 => new Array(x0),
      WB: s => s.trimRight(),
      WC: Function.prototype.call.bind(DataView.prototype.setInt8),
      WD: (x0,x1) => x0.createElement(x1),
      WE: x0 => x0.value,
      WF: (x0,x1) => x0.vibrate(x1),
      WG: x0 => x0.deltaMode,
      WH: x0 => x0.next(),
      WI: x0 => x0.displayWidth,
      WJ: (x0,x1) => { x0.width = x1 },
      X: o => [o],
      XB: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      XC: Function.prototype.call.bind(DataView.prototype.getInt8),
      XD: x0 => x0.body,
      XE: x0 => x0.selectionDirection,
      XF: (o, p) => p in o,
      XG: x0 => x0.deltaY,
      XH: x0 => x0.value,
      XI: x0 => x0.duration,
      XJ: (x0,x1) => x0.transferFromImageBitmap(x1),
      Y: (o0, o1) => [o0, o1],
      YB: () => ({}),
      YC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      YD: x0 => x0.remove(),
      YE: x0 => x0.selectionStart,
      YF: x0 => x0.arrayBuffer(),
      YG: x0 => x0.deltaX,
      YH: x0 => x0.done,
      YI: (x0,x1) => x0.decode(x1),
      YJ: x0 => x0.rasterEndMilliseconds,
      Z: (o0, o1, o2) => [o0, o1, o2],
      ZB: (o, p, v) => o[p] = v,
      ZC: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      ZD: (x0,x1) => x0.getPropertyValue(x1),
      ZE: x0 => x0.selectionEnd,
      ZF: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      ZG: x0 => x0.wheelDeltaY,
      ZH: (o, m, a) => o[m].apply(o, a),
      ZI: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      ZJ: x0 => x0.rasterStartMilliseconds,
      a: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      aB: () => [],
      aC: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      aD: (x0,x1) => x0.warn(x1),
      aE: x0 => x0.value,
      aF: x0 => x0.status,
      aG: x0 => x0.wheelDeltaX,
      aH: x0 => x0.iterator,
      aI: x0 => x0.image,
      aJ: x0 => x0.imageBitmaps,
      b: (x0,x1,x2) => { x0[x1] = x2 },
      bB: (a, i) => a.push(i),
      bC: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      bD: x0 => x0.console,
      bE: x0 => x0.selectionDirection,
      bF: (x0,x1) => x0.fetch(x1),
      bG: x0 => x0.bottom,
      bH: () => globalThis.Symbol,
      bI: x0 => x0.close(),
      bJ: x0 => x0.canvasKitMaximumSurfaces,
      c: o => o,
      cB: x0 => new Int8Array(x0),
      cC: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      cD: (x0,x1) => { x0.id = x1 },
      cE: x0 => x0.selectionStart,
      cF: x0 => x0.content,
      cG: x0 => x0.right,
      cH: (x0,x1) => new Intl.Segmenter(x0,x1),
      cI: x0 => new window.ImageDecoder(x0),
      cJ: x0 => x0.nextSibling,
      d: (o, p) => o[p],
      dB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      dC: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      dD: (x0,x1) => x0.requestAnimationFrame(x1),
      dE: x0 => x0.selectionEnd,
      dF: x0 => x0.document,
      dG: x0 => x0.clientY,
      dH: x0 => x0.Segmenter,
      dI: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      dJ: (x0,x1) => x0.debug(x1),
      e: () => globalThis,
      eB: x0 => new Uint8Array(x0),
      eC: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      eD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eE: (x0,x1) => { x0.name = x1 },
      eF: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      eG: x0 => x0.clientX,
      eH: x0 => x0.buffer,
      eI: x0 => x0.name,
      eJ: x0 => x0.hostElement,
      f: (x0,x1) => ({addView: x0,removeView: x1}),
      fB: x0 => new Uint8ClampedArray(x0),
      fC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      fD: x0 => x0.now(),
      fE: (x0,x1) => { x0.placeholder = x1 },
      fF: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      fG: x0 => x0.changedTouches,
      fH: x0 => x0.wasmMemory,
      fI: x0 => x0.repetitionCount,
      fJ: x0 => x0.location,
      g: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gB: x0 => new Int16Array(x0),
      gC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      gD: x0 => x0.performance,
      gE: (x0,x1) => { x0.autocomplete = x1 },
      gF: (x0,x1) => x0.querySelector(x1),
      gG: x0 => x0.key,
      gH: () => globalThis.window._flutter_skwasmInstance,
      gI: x0 => x0.frameCount,
      gJ: (x0,x1) => x0.getModifierState(x1),
      h: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      hB: x0 => new Uint16Array(x0),
      hC: b => !!b,
      hD: (x0,x1) => x0.unregister(x1),
      hE: (x0,x1) => { x0.type = x1 },
      hF: (x0,x1) => x0.querySelectorAll(x1),
      hG: x0 => x0.identifier,
      hH: () => new TextDecoder(),
      hI: x0 => x0.selectedTrack,
      hJ: x0 => x0.metaKey,
      i: (x0,x1) => x0.exec(x1),
      iB: x0 => new Int32Array(x0),
      iC: x0 => x0.history,
      iD: () => globalThis.window.FinalizationRegistry,
      iE: (x0,x1) => { x0.name = x1 },
      iF: x0 => x0.tabIndex,
      iG: x0 => x0.touches,
      iH: (map, o, v) => map.set(o, v),
      iI: x0 => x0.completed,
      iJ: x0 => x0.altKey,
      j: x0 => x0.length,
      jB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      jC: () => globalThis.window,
      jD: x0 => new window.FinalizationRegistry(x0),
      jE: (x0,x1) => { x0.placeholder = x1 },
      jF: x0 => x0.parentNode,
      jG: x0 => x0.pressure,
      jH: (map, o) => map.get(o),
      jI: x0 => x0.ready,
      jJ: x0 => x0.ctrlKey,
      k: o => o,
      kB: x0 => new Uint32Array(x0),
      kC: x0 => x0.search,
      kD: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      kE: (x0,x1) => { x0.scrollTop = x1 },
      kF: x0 => x0.clientY,
      kG: x0 => x0.tiltY,
      kH: () => new WeakMap(),
      kI: x0 => x0.tracks,
      kJ: x0 => x0.isComposing,
      l: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      lB: x0 => new Float32Array(x0),
      lC: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      lD: x0 => x0.scale,
      lE: x0 => x0.tagName,
      lF: x0 => x0.clientX,
      lG: x0 => x0.tiltX,
      lH: x0 => x0.debugSkipFontRetryDelay,
      lI: () => globalThis.window.ImageDecoder,
      lJ: x0 => x0.code,
      m: (x0,x1) => { x0.lastIndex = x1 },
      mB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      mC: x0 => x0.location,
      mD: x0 => x0.visualViewport,
      mE: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      mF: x0 => x0.shiftKey,
      mG: x0 => x0.pointerType,
      mH: (x0,x1,x2) => x0.set(x1,x2),
      mI: (x0,x1,x2) => x0.setItem(x1,x2),
      mJ: x0 => x0.repeat,
      n: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      nB: x0 => new Float64Array(x0),
      nC: x0 => x0.pathname,
      nD: x0 => x0.devicePixelRatio,
      nE: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      nF: x0 => x0.disconnect(),
      nG: x0 => x0.pointerId,
      nH: x0 => x0.fontFallbackBaseUrl,
      nI: x0 => x0.localStorage,
      nJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      o: o => o instanceof RegExp,
      oB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      oC: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      oD: (d, digits) => d.toFixed(digits),
      oE: x0 => x0.visibilityState,
      oF: x0 => new Intl.Locale(x0),
      oG: x0 => x0.getCoalescedEvents(),
      oH: x0 => x0.language,
      oI: () => globalThis.window,
      oJ: x0 => x0.extraAssets,
      p: o => o,
      pB: x0 => new ArrayBuffer(x0),
      pC: o => Object.keys(o),
      pD: x0 => x0.maxHeight,
      pE: x0 => x0.hasFocus(),
      pF: x0 => x0.region,
      pG: x0 => x0.blur(),
      pH: (handle) => clearInterval(handle),
      pI: (o, p) => p in o,
      pJ: x0 => x0.fontManifest,
      q: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      qB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      qC: f => f.dartFunction,
      qD: x0 => x0.maxWidth,
      qE: x0 => x0.relatedTarget,
      qF: x0 => x0.script,
      qG: (x0,x1) => x0.setPointerCapture(x1),
      qH: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      qI: x0 => x0.groups,
      qJ: x0 => x0.assetManifest,
      r: x0 => x0.dotAll,
      rB: (x0,x1,x2) => new DataView(x0,x1,x2),
      rC: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      rD: x0 => x0.minHeight,
      rE: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      rF: x0 => x0.language,
      rG: x0 => x0.button,
      rH: () => Date.now(),
      rI: x0 => x0.pop(),
      rJ: x0 => x0.buildConfig,
      s: x0 => x0.unicode,
      sB: (o, p) => o[p],
      sC: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      sD: x0 => x0.minWidth,
      sE: x0 => x0.keyCode,
      sF: x0 => x0.languages,
      sG: (x0,x1) => x0.prepend(x1),
      sH: (x0,x1,x2) => x0.insertBefore(x1,x2),
      sI: (x0,x1) => x0.createElement(x1),
      sJ: x0 => x0.getReader(),
      t: x0 => x0.ignoreCase,
      tB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      tC: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      tD: x0 => x0.height,
      tE: (x0,x1) => x0.scrollIntoView(x1),
      tF: (x0,x1) => x0.observe(x1),
      tG: x0 => x0.innerHeight,
      tH: x0 => x0.id,
      tI: (x0,x1) => x0.append(x1),
      tJ: x0 => x0.value,
      u: x0 => x0.multiline,
      uB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      uC: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      uD: x0 => x0.width,
      uE: x0 => x0.multiViewEnabled,
      uF: x0 => new ResizeObserver(x0),
      uG: x0 => x0.height,
      uH: x0 => x0.offsetHeight,
      uI: (x0,x1,x2) => x0.insertRule(x1,x2),
      uJ: x0 => x0.done,
      v: (string, token) => string.split(token),
      vB: o => o.byteOffset,
      vC: (o, i) => o[i],
      vD: x0 => x0.screen,
      vE: x0 => x0.parent,
      vF: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      vG: x0 => x0.width,
      vH: x0 => x0.offsetWidth,
      vI: (x0,x1) => x0.add(x1),
      vJ: x0 => x0.read(),
      w: (a, i) => a[i],
      wB: o => o.buffer,
      wC: o => o.length,
      wD: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      wE: (x0,x1) => x0.replaceWith(x1),
      wF: x0 => globalThis.parseFloat(x0),
      wG: x0 => x0.clientHeight,
      wH: x0 => x0.stopPropagation(),
      wI: (x0,x1,x2) => x0.addEventListener(x1,x2),
      wJ: x0 => x0.body,
      x: a => a.length,
      xB: (b, o) => new DataView(b, o),
      xC: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      xD: (x0,x1) => x0.removeProperty(x1),
      xE: (x0,x1) => { x0.className = x1 },
      xF: (x0,x1) => x0.getComputedStyle(x1),
      xG: x0 => x0.clientWidth,
      xH: x0 => x0.disabled,
      xI: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      xJ: (x0,x1) => new OffscreenCanvas(x0,x1),
      y: o => o instanceof Array,
      yB: (b, o, l) => new DataView(b, o, l),
      yC: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      yD: (x0,x1) => x0.appendChild(x1),
      yE: (x0,x1) => { x0.action = x1 },
      yF: x0 => x0.documentElement,
      yG: x0 => x0.innerWidth,
      yH: (x0,x1) => { x0.min = x1 },
      yI: x0 => x0.preventDefault(),
      yJ: x0 => x0.assetBase,
      z: (string, times) => string.repeat(times),
      zB: Function.prototype.call.bind(DataView.prototype.getUint8),
      zC: x0 => x0.state,
      zD: x0 => x0.debugShowSemanticsNodes,
      zE: (x0,x1) => { x0.method = x1 },
      zF: (x0,x1) => x0.get(x1),
      zG: (x0,x1) => x0.removeChild(x1),
      zH: (x0,x1) => { x0.max = x1 },
      zI: x0 => x0.createRange(),
      zJ: x0 => x0.loader,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
