#
# Copyright (C) 2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

real_sec_date_file := build/core/version_defaults.mk
intermediate_real_sec_date_prop := $(call intermediates-dir-for,ETC,real_sec_date_prop)/real_sec_date.prop

TARGET_SYSTEM_PROP += $(intermediate_real_sec_date_prop)

$(intermediate_real_sec_date_prop): $(real_sec_date_file)
	@echo Extract real security date: $@
	@mkdir -p $(dir $@)
	$(hide) echo > $@
	$(hide) echo -n "ro.build.version.real_security_patch=" >> $@
	$(hide) grep "PLATFORM_SECURITY_PATCH :=" $(real_sec_date_file) | awk '{print $$NF}' >> $@
