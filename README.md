# matlab-mightex-led-controller
MATLAB Class for Communication With Mightex Universal LED Controller (SLC-XXXX Series).  This does not implement 100% of the available functionality. 

# Dependencies

- Download the SLC-Series LED Controller Software Package from the Mightex Website.  Inside the downloaded .zip folder, navigate to SDK/lib and SDK/x64_lib.  If using 64-bit version of MATLAB, you will need 

# Special Instructions for 64-Bit Versions of Matlab

- MATLAB > R2017a does not ship with a C compiler, which is a requirement of the `loadlib` and `calllib` external interface.  MATLAB recommends installing MinGW 4.9.2.  This must be installed

- The x64_lib/Mightex_LEDDriver_SDK.h header file is not compatible with 64-bit MATLAB because it assumes a C++ compiler, where MATLAB compiles all code as vanilla C.  A modified, compatible version of the header is included in this repo.

- The `extern C` declaration in the header needs to be wrapped in a `ifdef __cplusplus` as shown below.  When MATLAB compiles this file with its C compilier, the `extern "C"` declaration is not recognized since only C++ compilers recognize that declaration.

```
#ifdef SDK_EXPORTS
    #ifdef __cplusplus
        #define SDK_API extern "C" __declspec(dllexport) SDK_RETURN_CODE _cdecl
    #else
        #define SDK_API __declspec(dllexport) SDK_RETURN_CODE _cdecl
    #endif
#else
    #ifdef __cplusplus
        #define SDK_API extern "C" __declspec(dllimport) SDK_RETURN_CODE _cdecl
    #else
        #define SDK_API __declspec(dllimport) SDK_RETURN_CODE _cdecl
    #endif
#endif
```

The header that mightex ships assumes a C++ compiler