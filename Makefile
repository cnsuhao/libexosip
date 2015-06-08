#*********************************************************************************************************
# libexosip Makefile
# target -> libexosip.a  
#           libexosip.so
#			sip_reg
#*********************************************************************************************************

#*********************************************************************************************************
# include config.mk
#*********************************************************************************************************
CONFIG_MK_EXIST = $(shell if [ -f ../config.mk ]; then echo exist; else echo notexist; fi;)
ifeq ($(CONFIG_MK_EXIST), exist)
include ../config.mk
else
CONFIG_MK_EXIST = $(shell if [ -f config.mk ]; then echo exist; else echo notexist; fi;)
ifeq ($(CONFIG_MK_EXIST), exist)
include config.mk
else
CONFIG_MK_EXIST =
endif
endif

#*********************************************************************************************************
# check configure
#*********************************************************************************************************
check_defined = \
    $(foreach 1,$1,$(__check_defined))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $(value 2), ($(strip $2)))))

$(call check_defined, CONFIG_MK_EXIST, Please configure this project in RealCoder or \
create a config.mk file!)
$(call check_defined, SYLIXOS_BASE_PATH, SylixOS base project path)
$(call check_defined, TOOLCHAIN_PREFIX, the prefix name of toolchain)
$(call check_defined, DEBUG_LEVEL, debug level(debug or release))

#*********************************************************************************************************
# configure area you can set the following config to you own system
# FPUFLAGS (-mfloat-abi=softfp -mfpu=vfpv3 ...)
# CPUFLAGS (-mcpu=arm920t ...)
# NOTICE: libsylixos, BSP and other kernel modules projects CAN NOT use vfp!
#*********************************************************************************************************
FPUFLAGS = 
CPUFLAGS = -mcpu=arm920t $(FPUFLAGS)

#*********************************************************************************************************
# toolchain select
#*********************************************************************************************************
CC  = $(TOOLCHAIN_PREFIX)gcc
CXX = $(TOOLCHAIN_PREFIX)g++
AS  = $(TOOLCHAIN_PREFIX)gcc
AR  = $(TOOLCHAIN_PREFIX)ar
LD  = $(TOOLCHAIN_PREFIX)g++

#*********************************************************************************************************
# do not change the following code
# buildin internal application source
#*********************************************************************************************************
#*********************************************************************************************************
# libexosip src(s) file
#*********************************************************************************************************
LIB_SRCS = \
exosip/src/eXcall_api.c \
exosip/src/eXconf.c \
exosip/src/eXinsubscription_api.c \
exosip/src/eXmessage_api.c \
exosip/src/eXoptions_api.c \
exosip/src/eXosip.c \
exosip/src/eXpublish_api.c \
exosip/src/eXrefer_api.c \
exosip/src/eXregister_api.c \
exosip/src/eXsubscription_api.c \
exosip/src/eXtl_dtls.c \
exosip/src/eXtl_tcp.c \
exosip/src/eXtl_tls.c \
exosip/src/eXtl_udp.c \
exosip/src/eXtransport.c \
exosip/src/eXutils.c \
exosip/src/inet_ntop.c \
exosip/src/jauth.c \
exosip/src/jcall.c \
exosip/src/jcallback.c \
exosip/src/jdialog.c \
exosip/src/jevents.c \
exosip/src/jnotify.c \
exosip/src/jpipe.c \
exosip/src/jpublish.c \
exosip/src/jreg.c \
exosip/src/jrequest.c \
exosip/src/jresponse.c \
exosip/src/jsubscribe.c \
exosip/src/milenage.c \
exosip/src/misc.c \
exosip/src/rijndael.c \
exosip/src/sdp_offans.c \
exosip/src/udp.c \

#*********************************************************************************************************
# sip_reg src(s) file
#*********************************************************************************************************
EXE_SRCS = \
exosip/tools/sip_reg.c

#*********************************************************************************************************
# build path
#*********************************************************************************************************
ifeq ($(DEBUG_LEVEL), debug)
OUTDIR = Debug
else
OUTDIR = Release
endif

OUTPATH = ./$(OUTDIR)
OBJPATH = $(OUTPATH)/obj
DEPPATH = $(OUTPATH)/dep

#*********************************************************************************************************
#  target
#*********************************************************************************************************
LIB = $(OUTPATH)/libexosip.a
DLL = $(OUTPATH)/libexosip.so
EXE = $(OUTPATH)/sip_reg

#*********************************************************************************************************
# libexosip objects
#*********************************************************************************************************
LIB_OBJS = $(addprefix $(OBJPATH)/, $(addsuffix .o, $(basename $(LIB_SRCS))))
LIB_DEPS = $(addprefix $(DEPPATH)/, $(addsuffix .d, $(basename $(LIB_SRCS))))

#*********************************************************************************************************
# sip_reg objects
#*********************************************************************************************************
EXE_OBJS = $(addprefix $(OBJPATH)/, $(addsuffix .o, $(basename $(EXE_SRCS))))
EXE_DEPS = $(addprefix $(DEPPATH)/, $(addsuffix .d, $(basename $(EXE_SRCS))))

#*********************************************************************************************************
# include path
#*********************************************************************************************************
INCDIR  = -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS"
INCDIR += -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS/include"
INCDIR += -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS/include/inet"
INCDIR += -I"../libosip/osip/include"
INCDIR += -I"./exosip/include"

#*********************************************************************************************************
# compiler preprocess
#*********************************************************************************************************
DSYMBOL  = -DSYLIXOS
DSYMBOL += -DSYLIXOS_LIB

#*********************************************************************************************************
# depend dynamic library
#*********************************************************************************************************
DEPEND_DLL = -losip -lcextern
EXE_DEPEND_DLL = -lexosip -losip -lcextern -lvpmpdm

#*********************************************************************************************************
# depend dynamic library search path
#*********************************************************************************************************
DEPEND_DLL_PATH      = -L"$(SYLIXOS_BASE_PATH)/libcextern/$(OUTDIR)"
DEPEND_DLL_PATH     += -L"../libosip/$(OUTDIR)"

EXE_DEPEND_DLL_PATH  = -L"$(SYLIXOS_BASE_PATH)/libcextern/$(OUTDIR)"
EXE_DEPEND_DLL_PATH += -L"$(SYLIXOS_BASE_PATH)/libsylixos/$(OUTDIR)"
EXE_DEPEND_DLL_PATH += -L"../libosip/$(OUTDIR)"
EXE_DEPEND_DLL_PATH += -L$(OUTPATH)

#*********************************************************************************************************
# compiler optimize
#*********************************************************************************************************
ifeq ($(DEBUG_LEVEL), debug)
OPTIMIZE = -O0 -g3 -gdwarf-2
else
OPTIMIZE = -O2 -g1 -gdwarf-2											# Do NOT use -O3 and -Os
endif										    						# -Os is not align for function
																		# loop and jump.
#*********************************************************************************************************
# depends and compiler parameter (cplusplus in kernel MUST NOT use exceptions and rtti)
#*********************************************************************************************************
DEPENDFLAG  = -MM
CXX_EXCEPT  = -fno-exceptions -fno-rtti
COMMONFLAGS = $(CPUFLAGS) $(OPTIMIZE) -Wall -fmessage-length=0 -fsigned-char -fno-short-enums
ASFLAGS     = -x assembler-with-cpp $(DSYMBOL) $(INCDIR) $(COMMONFLAGS) -c
CFLAGS      = $(DSYMBOL) $(INCDIR) $(COMMONFLAGS) -fPIC -c
CXXFLAGS    = $(DSYMBOL) $(INCDIR) $(CXX_EXCEPT) $(COMMONFLAGS) -fPIC -c
ARFLAGS     = -r

#*********************************************************************************************************
# define some useful variable
#*********************************************************************************************************
DEPEND          = $(CC)  $(DEPENDFLAG) $(CFLAGS)
DEPEND.d        = $(subst -g ,,$(DEPEND))
COMPILE.S       = $(AS)  $(ASFLAGS)
COMPILE_VFP.S   = $(AS)  $(ASFLAGS)
COMPILE.c       = $(CC)  $(CFLAGS)
COMPILE.cxx     = $(CXX) $(CXXFLAGS)

#*********************************************************************************************************
# target
#*********************************************************************************************************
all: $(LIB) $(DLL) $(EXE)
		@echo create "$(LIB) $(DLL) $(EXE)" success.

#*********************************************************************************************************
# include depends
#*********************************************************************************************************
ifneq ($(MAKECMDGOALS), clean)
ifneq ($(MAKECMDGOALS), clean_project)
sinclude $(LIB_DEPS) $(EXE_DEPS)
endif
endif

#*********************************************************************************************************
# create depends files
#*********************************************************************************************************
$(DEPPATH)/%.d: %.c
		@echo creating $@
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		@rm -f $@; \
		echo -n '$@ $(addprefix $(OBJPATH)/, $(dir $<))' > $@; \
		$(DEPEND.d) $< >> $@ || rm -f $@; exit;

$(DEPPATH)/%.d: %.cpp
		@echo creating $@
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		@rm -f $@; \
		echo -n '$@ $(addprefix $(OBJPATH)/, $(dir $<))' > $@; \
		$(DEPEND.d) $< >> $@ || rm -f $@; exit;

#*********************************************************************************************************
# compile source files
#*********************************************************************************************************
$(OBJPATH)/%.o: %.S
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.S) $< -o $@

$(OBJPATH)/%.o: %.c
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.c) $< -o $@

$(OBJPATH)/%.o: %.cpp
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.cxx) $< -o $@

#*********************************************************************************************************
# link libexosip.a object files
#*********************************************************************************************************
$(LIB): $(LIB_OBJS)
		$(AR) $(ARFLAGS) $(LIB) $(LIB_OBJS)

#*********************************************************************************************************
# link libexosip.so object files
#*********************************************************************************************************
$(DLL): $(LIB_OBJS)
		$(LD) $(CPUFLAGS) -nostdlib -fPIC -shared -o $(DLL) $(LIB_OBJS) \
		$(DEPEND_DLL_PATH) $(DEPEND_DLL) -lm -lgcc
		
#*********************************************************************************************************
# link sip_reg object files
#*********************************************************************************************************
$(EXE): $(EXE_OBJS)
		$(LD) $(CPUFLAGS) -nostdlib -fPIC -shared -o $(EXE) $(EXE_OBJS) \
		$(EXE_DEPEND_DLL_PATH) $(EXE_DEPEND_DLL) -lm -lgcc

#*********************************************************************************************************
# clean
#*********************************************************************************************************
.PHONY: clean
.PHONY: clean_project

#*********************************************************************************************************
# clean objects
#*********************************************************************************************************
clean:
		-rm -rf $(LIB)
		-rm -rf $(DLL)
		-rm -rf $(EXE)
		-rm -rf $(OBJPATH)
		-rm -rf $(DEPPATH)

#*********************************************************************************************************
# clean project
#*********************************************************************************************************
clean_project:
		-rm -rf $(OUTPATH)

#*********************************************************************************************************
# END
#*********************************************************************************************************
