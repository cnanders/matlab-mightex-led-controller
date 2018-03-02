MATLAB Class for Communication With Mightex Universal LED Controller (SLC-XXXX Series).  This does not implement 100% of the available functionality. 

# Dependencies

- SLC-Series LED Controller Software Package from the Mightex Website.  This is included in the `sdk` folder of this repo.  Inside the downloaded .zip folder, navigate to SDK/lib and SDK/x64_lib.  If using 64-bit version of MATLAB, you will need 

# Gotchas For 64-Bit Versions of Matlab



## Modified x64/Mightex_LEDDriver_SDK.h file

- The x64_lib/Mightex_LEDDriver_SDK.h header file is not compatible with 64-bit MATLAB because it assumes a C++ compiler, where MATLAB compiles all code as vanilla C.  A modified, compatible version of the header is included in the `/sdk` folder of this repo. The `extern C` declaration of the original header has been wrapped in a `ifdef __cplusplus` and has been removed in the case where `ifdef __cplusplus` fails, as shown below.  

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
## Installing a Compatible C Compiler

- MATLAB > R2017a does not ship with a C compiler, which is a requirement of the `loadlib` and `calllib` external interface.  
- MATLAB recommends installing MinGW 4.9.2 but for an unknown readon, MinGW compiler is not compatible with the DLL that Mightex ships.  A different compiler must be installed.
- The [list of supported and compatible compilers for R2017A](https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/support/sysreq/files/SystemRequirements-Release2017a_SupportedCompilers.pdf) shows that Visual C++ 2017 Family is compatible and it was found that the Visual C++ 2017 Family compiler works with the DLL so it is recommended to [install Visual C++ 2017 Family](#install-visual-c++) and then [configure the MATLAB C compiler to use Visual C++ 2017 compiler](#configure-matlab-compiler)



<a name="install-visual-c++"></a>
# How To Install Visual C++ 2017 Family

- Google Visual Studio 2017
- Download and insatll Visual Studio 2017 Community
- On the "Workloads" tab of the installer, choose "Desktop development with C++"
- After the installation, reboot the machine.


The header that mightex ships assumes a C++ compiler

<a name="configure-matlab-compiler"></a>
# Configure MATLAB C Compiler To Use Visual Studio 2017 Family

- Quit MATLAB
- MATLAB R2017a requires a patch to use Visual Studio C++ 2017 Family compiler. Follow the instructions in this [bug report](https://www.mathworks.com/support/bugreports/1487958) to install the patch.  What this patch does is put the `msvc2017.xml` and `msvcpp2017.xml` config files in `C:\Program Files\MATLAB\R2017a\bin\win64\mexopts`
- Open MATLAB
- Run `mex -setup c`
- At the bottom of the output, it will say "to choose a different compiler select one from the follwing" and a link to Microsoft Visual C++ 2017 (C) will be present.  Click that link.

