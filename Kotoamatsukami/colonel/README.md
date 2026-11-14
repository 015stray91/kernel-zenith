# Colonel - Snapdragon Profile (SProf)

## Purpose
VFS Environment Shaping via Qualcomm EUD hardware probe for Snapdragon 6450.

## Architecture
```
FLAGS = Logic (kernel config enables capabilities)
C/H Files = Movement (actual code implementation)  
DISC = Proof (testing/validation)
PATCH = Seal (integration into kernel)
```

## Files
- `sprof_types.h` - Hardware profile and spoofing structures
- `sprof_core.h` - Function declarations
- `sprof_eud.c` - Qualcomm EUD QFPROM/cpufreq probe for SM6450
- `sprof_proc.c` - /proc/* content generation from hw profile
- `sprof_env.c` - Environment variable spoofing
- `sprof_profile.c` - Profile lifecycle management
- `sprof_vfs.c` - VFS interception layer
- `sprof_main.c` - Module init/exit and sysfs/proc interface

## Clang 17 Wrapper Usage
```bash
# Use Kotoamatsukami to flatten/obfuscate the kernel build
export CC=/path/to/colonel/build_kernel.sh
export CLANG17=clang-17
export OBFUSCATE=1
export OBF_PASSES="flatten,bogus-control-flow,substitution"

# Normal kernel build
make O=out ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
```

## Build Integration
Integrates into kernel-msm-1 at `fs/koto/colonel/`

## Cross-References
- Super-Builders uses this repo for the Clang 17 wrapper: `015stray91/Super-Builders@015stray91`
- Kernel-1 references this repo as outside_wrapper_defense_active
- kernel-msm-1 has the colonel source that this wraps
