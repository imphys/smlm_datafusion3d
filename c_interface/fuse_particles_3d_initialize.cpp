
#include "fuse_particles_3d_initialize.h"
#include "mcc_fuse_particles_3d.h"

// Global flag indicating that the Matlab runtime library has been started
int mcr_initialized = 0;

// Global flag indicating that the MCC-generated dll has been initialized
int mcc_fuse_particles_3d_initialized = 0;

char path[MAX_PATH];
HMODULE hm = NULL;

int mcr_start()
{
    if (mcr_initialized == 0)
    {
        mclInitializeApplication(NULL, 0);
        mcr_initialized = (int)mclIsMCRInitialized();
    }
    return mcr_initialized;
}


int mcr_stop()
{
    if (mcr_initialized == 1)
    {
        mclTerminateApplication();
        mcr_initialized = (int)mclIsMCRInitialized();
    }
    return mcr_initialized;
}

#ifdef _WIN32
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>

int dummy_function(int argc, void *argv[])
{
    return 0;
}

int load_dll(char * mcc_dll_name)
{
    char mcc_dll_path[MAX_PATH] = "";

    // Get the file path of the current DLL

    int return_code = get_current_dll_path();

    if (return_code != 0)
    {
        // Error getting current DLL path
        return return_code;
    }

    // set a path to the mcc_fuse_particles_3d.dll library

    char * search_char = "\\";
    char * last_path_sep = strrchr(path, search_char[0]);
    int dir_path_length = (last_path_sep - path) + 1;
    strncat_s(mcc_dll_path, path, (size_t)dir_path_length);
    strcat_s(mcc_dll_path, mcc_dll_name);

    // test if the mcc-generated dll is already loaded

    HMODULE loaded_module_handle = GetModuleHandle((LPCSTR)mcc_dll_name);

    if (loaded_module_handle == NULL)
    {
        // load the mcc-generated dll

        HMODULE module_handle = LoadLibraryA((LPCSTR)mcc_dll_path);

        if (module_handle == NULL)
        {
            int error_code = (int)GetLastError();
            return error_code;
        }
    }

    return 0;
}


int get_current_dll_path()
{
    // Get the file path of the current DLL

    int ret = 0;

    if (GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
        GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
        (LPCSTR)&dummy_function, &hm) == 0)
    {
        ret = (int)GetLastError();
        fprintf(stderr, "GetModuleHandle failed, error = %d\n", ret);
    }
    if (GetModuleFileName(hm, path, sizeof(path)) == 0)
    {
        ret = (int)GetLastError();
        fprintf(stderr, "GetModuleFileName failed, error = %d\n", ret);
    }

    return ret;
}


int fuse_particles_3d_initialize_win32()
{
    load_dll("mcc_fuse_particles_3d.dll");

    return 0;
}

#endif