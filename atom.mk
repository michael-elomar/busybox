
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := busybox
LOCAL_CATEGORY_PATH := system

# Variables
BUSYBOX_DIR := $(LOCAL_PATH)
BUSYBOX_VERSION := 1.36.1

# Build directory and source sirectory inside build directory (after unpacking)
# Busybox configuration file
BUSYBOX_SRC_DIR := $(LOCAL_PATH)

BUSYBOX_CFLAGS := \
	$(TARGET_GLOBAL_CFLAGS) \
	-Wno-sign-compare -Wno-error=format-security \
	$(call normalize-c-includes,$(TARGET_GLOBAL_C_INCLUDES))

# Make arguments
BUSYBOX_MAKE_ARGS := \
	ARCH=$(TARGET_ARCH) \
	CC="$(CCACHE) $(TARGET_CC)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CROSS="$(TARGET_CROSS)" \
	CONFIG_PREFIX="$(TARGET_OUT_STAGING)" \
	PREFIX="$(TARGET_OUT_STAGING)" \
	CFLAGS="$(BUSYBOX_CFLAGS)" \
	LDFLAGS="$(TARGET_GLOBAL_LDFLAGS)" \
	V=$(V)

# Build
$(LOCAL_MODULE): $(TARGET_CONFIG_DIR)/$(LOCAL_MODULE).config
	@cp $< $(BUSYBOX_SRC_DIR)/.config
	$(Q) yes "" 2>/dev/null | $(MAKE) $(BUSYBOX_MAKE_ARGS) -C $(BUSYBOX_SRC_DIR)
	@echo "Building busybox"
	$(Q) $(MAKE) $(BUSYBOX_MAKE_ARGS) -C $(BUSYBOX_SRC_DIR) SKIP_STRIP=y
	@echo "Installing busybox"
	$(Q) $(MAKE) $(BUSYBOX_MAKE_ARGS) -C $(BUSYBOX_SRC_DIR) install
	@rm -rf $(TARGET_OUT_STAGING)/linuxrc

# Busybox configuration
.PHONY: busybox-menuconfig
busybox-menuconfig: $(BUSYBOX_SRC_DIR)/.config
	@echo "Configuring busybox: $(BUSYBOX_CONFIG_FILE)"
	$(Q) $(MAKE) $(BUSYBOX_MAKE_ARGS) -C $(BUSYBOX_SRC_DIR) menuconfig
	@cp -af $(BUSYBOX_SRC_DIR)/.config $(BUSYBOX_CONFIG_FILE)


# Custom clean rule. LOCAL_MODULE_FILENAME already deleted by common rule
.PHONY: busybox-clean
busybox-clean:
	$(Q)if [ -d $(BUSYBOX_SRC_DIR) ]; then \
		$(MAKE) $(BUSYBOX_MAKE_ARGS) -C $(BUSYBOX_SRC_DIR) uninstall \
			|| echo "Ignoring uninstall errors"; \
		$(MAKE) $(BUSYBOX_MAKE_ARGS) -C $(BUSYBOX_SRC_DIR) clean \
			|| echo "Ignoring clean errors"; \
	fi

include $(BUILD_CUSTOM)
