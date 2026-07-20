/* GHC_PACKAGES base integer-gmp ghc-prim rts ffi-1.0
*/
#include "Stg.h"
EI_(base_GHCziBase_unpackCStringzh_closure);
static StgWord sf8_srt[] = {
(W_)&base_GHCziBase_unpackCStringzh_closure
};

II_(sf8_info);
static StgWord sf8_closure[] = {
(W_)&sf8_info, 0x0, 0x0, 0x0
};

static char cfg_str[] = "Hello World!";

static StgWord sf8_info[] = {
((W_)&sf8_srt+0), 0x0, 0x100000016UL
};

EI_(base_GHCziBase_unpackCStringzh_closure);
IF_(sf8_entry) {
FB_
if ((W_)(((W_)Sp - 0x10UL) < (W_)SpLim)) goto _cfj;
Hp=Hp+2;
if ((W_)((W_)Hp > (W_)HpLim)) goto _cfj;
Hp[-1] = (W_)&stg_CAF_BLACKHOLE_info;
;EF_(newCAF);
{void (*ghcFunPtr)(void *);
ghcFunPtr = ((void (*)(void *))(W_)&newCAF);
__DISCARD__();
ghcFunPtr((void *)R1.w);;}
R1.p[1] = (W_)Hp-8;
*R1.p = (W_)&stg_IND_STATIC_info;
Sp[-2] = (W_)&stg_upd_frame_info;
Sp[-1] = (W_)Hp-8;
R1.w = (W_)&base_GHCziBase_unpackCStringzh_closure;
R2.w = (W_)&cfg_str;
Sp=Sp-2;
JMP_((W_)&stg_ap_n_fast);
_cfj:
HpAlloc = 0x10UL;
JMP_(stg_gc_enter_1);
FE_
}
EI_(base_SystemziIO_putStrLn_closure);
II_(sf8_closure);
StgWord Main_main_srt[] = {
(W_)&base_SystemziIO_putStrLn_closure, (W_)&sf8_closure
};

EI_(Main_main_info);
StgWord Main_main_closure[] = {
(W_)&Main_main_info, 0x0, 0x0, 0x0
};

StgWord Main_main_info[] = {
((W_)&Main_main_srt+0), 0x0, 0x300000016UL
};

EI_(base_SystemziIO_putStrLn_closure);
II_(sf8_closure);
FN_(Main_main_entry) {
FB_
if ((W_)(((W_)Sp - 0x10UL) < (W_)SpLim)) goto _cft;
Hp=Hp+2;
if ((W_)((W_)Hp > (W_)HpLim)) goto _cft;
Hp[-1] = (W_)&stg_CAF_BLACKHOLE_info;
;EF_(newCAF);
{void (*ghcFunPtr)(void *);
ghcFunPtr = ((void (*)(void *))(W_)&newCAF);
__DISCARD__();
ghcFunPtr((void *)R1.w);;}
R1.p[1] = (W_)Hp-8;
*R1.p = (W_)&stg_IND_STATIC_info;
Sp[-2] = (W_)&stg_upd_frame_info;
Sp[-1] = (W_)Hp-8;
R1.w = (W_)&base_SystemziIO_putStrLn_closure;
R2.w = (W_)&sf8_closure;
Sp=Sp-2;
JMP_((W_)&stg_ap_p_fast);
_cft:
HpAlloc = 0x10UL;
JMP_(stg_gc_enter_1);
FE_
}
EI_(base_GHCziTopHandler_runMainIO_closure);
EI_(Main_main_closure);
StgWord ZCMain_main_srt[] = {
(W_)&base_GHCziTopHandler_runMainIO_closure, (W_)&Main_main_closure
};

EI_(ZCMain_main_info);
StgWord ZCMain_main_closure[] = {
(W_)&ZCMain_main_info, 0x0, 0x0, 0x0
};

StgWord ZCMain_main_info[] = {
((W_)&ZCMain_main_srt+0), 0x0, 0x300000016UL
};

EI_(base_GHCziTopHandler_runMainIO_closure);
EI_(Main_main_closure);
FN_(ZCMain_main_entry) {
FB_
if ((W_)(((W_)Sp - 0x10UL) < (W_)SpLim)) goto _cfD;
Hp=Hp+2;
if ((W_)((W_)Hp > (W_)HpLim)) goto _cfD;
Hp[-1] = (W_)&stg_CAF_BLACKHOLE_info;
;EF_(newCAF);
{void (*ghcFunPtr)(void *);
ghcFunPtr = ((void (*)(void *))(W_)&newCAF);
__DISCARD__();
ghcFunPtr((void *)R1.w);;}
R1.p[1] = (W_)Hp-8;
*R1.p = (W_)&stg_IND_STATIC_info;
Sp[-2] = (W_)&stg_upd_frame_info;
Sp[-1] = (W_)Hp-8;
R1.w = (W_)&base_GHCziTopHandler_runMainIO_closure;
R2.w = (W_)&Main_main_closure;
Sp=Sp-2;
JMP_((W_)&stg_ap_p_fast);
_cfD:
HpAlloc = 0x10UL;
JMP_(stg_gc_enter_1);
FE_
}
static StgWord _module_registered[] = {
0x0
};


EF_(__stginit_base_Prelude_);
EF_(__stginit_base_GHCziTopHandler_);
FN_(__stginit_Main_) {
FB_
if ((W_)(0x0 != (*((P_)(W_)&_module_registered)))) goto _cfJ;
goto _cfL;
_cfJ:
Sp=Sp+1;
JMP_(Sp[-1]);
_cfL:
*((P_)(W_)&_module_registered) = 0x1UL;
Sp=Sp-1;
*Sp = (W_)&__stginit_base_Prelude_;
Sp=Sp-1;
*Sp = (W_)&__stginit_base_GHCziTopHandler_;
goto _cfJ;
FE_
}


EF_(__stginit_Main_);
FN_(__stginit_Main) {
FB_
JMP_((W_)&__stginit_Main_);
FE_
}


FN_(__stginit_ZCMain) {
FB_
Sp=Sp+1;
JMP_(Sp[-1]);
FE_
}
