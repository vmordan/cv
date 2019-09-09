cpu_cores=$(shell nproc)


# Additional tools.
klever="klever"
clade="clade"
cil="cil"
astraver_cil="astraver-cil"
benchexec="benchexec"
cif="cif"

# Directories
root_dir=$(shell pwd)
install_dir=tools
klever_dir=${install_dir}/${klever}
mea_lib=${install_dir}/${klever}/bridge/reports/mea/core.py
cil_dir=${install_dir}/${cil}
astraver_cil_dir=${install_dir}/${astraver_cil}
benchexec_dir=${install_dir}/${benchexec}
cif_dir=${install_dir}/${cif}
plugin_dir="plugin"

cpa_arch="build.tar.bz2"
compiled_cif_arch="cif.xz"

# Repositories
klever_repo="https://github.com/mutilin/klever.git"
clade_repo="https://github.com/mutilin/clade.git"
benchexec_repo="https://github.com/sosy-lab/benchexec.git"
cif_repo="https://forge.ispras.ru/git/cif.git"
cif_compiled_link="https://github.com/17451k/cif/releases/download/2019-03-12/cif-20190312-linux-x64.tar.xz"
cpa_trunk_repo="https://svn.sosy-lab.org/software/cpachecker/trunk"
cpa_branches_repo="https://svn.sosy-lab.org/software/cpachecker/branches"

include $(root_dir)/cpa.config


download-klever:
	@$(call download_tool,${klever},${klever_dir},${klever_repo})
	@cd ${klever_dir}; git checkout cv-v2.0; git pull

download-benchexec:
	@$(call download_tool,${benchexec},${benchexec_dir},${benchexec_repo})
	@cd ${benchexec_dir}; git checkout 1.16

download-cif:
	@$(call download_tool,${cif},${cif_dir},${cif_repo})
	@cd ${cif_dir}; git checkout ca907524; git submodule update

download-cif-compiled:
	@rm -f ${compiled_cif_arch}
	@cd ${install_dir}; wget ${cif_compiled_link} -O ${compiled_cif_arch}

download-cpa := $(addprefix download-cpa-,$(cpa_modes))
$(download-cpa):
	@$(call download_cpa,$(patsubst download-cpa-%,%,$@))
	
download: download-klever download-benchexec download-cif $(download-cpa)
	@echo "*** Downloading has been completed ***"


build-klever: download-klever
	@echo "*** Building ${klever} ***"
	@echo "from bridge.development import *" > ${klever_dir}/bridge/bridge/settings.py
	@echo "{}" > ${klever_dir}/bridge/bridge/db.json

build-benchexec: download-benchexec
	@echo "*** Building ${benchexec} ***"
	@cd ${benchexec_dir}; ./setup.py build

build-cif: download-cif
	@echo "*** Building ${cif} ***"
	@cd ${cif_dir}; make -j ${cpu_cores}

build-cif-compiled: download-cif-compiled
	@echo "*** Building compiled ${cif} ***"
	@rm -rf ${cif_dir}
	@cd ${install_dir}; tar -xf ${compiled_cif_arch}

build-cil:
	@echo "*** Building ${cil} ***"
	@rm -rf ${cil_dir}
	@cd ${install_dir}; tar -xf cil.xz

build-astraver-cil:
	@echo "*** Building ${astraver-cil} ***"
	@rm -rf ${astraver_cil_dir}
	@cd ${install_dir}; tar -xf astraver-cil.xz

build-cpa := $(addprefix build-cpa-,$(cpa_modes))
$(build-cpa):
	@make download-cpa-$(patsubst build-cpa-%,%,$@)
	@$(call build_cpa,$(patsubst build-cpa-%,%,$@))

build: build-klever build-benchexec build-cif build-cil $(build-cpa)
	@echo "*** Building has been completed ***"

clean-cpa := $(addprefix clean-cpa-,$(cpa_modes))
$(clean-cpa):
	@$(call clean_cpa,$(patsubst clean-cpa-%,%,$@))

rebuild-cpa := $(addprefix rebuild-cpa-,$(cpa_modes))
$(rebuild-cpa):
	@make clean-cpa-$(patsubst rebuild-cpa-%,%,$@)
	@make build-cpa-$(patsubst rebuild-cpa-%,%,$@)

rebuild-cpa: $(rebuild-cpa)
build-cpa: $(build-cpa)

install-cpa := $(addprefix install-cpa-,$(cpa_modes))
$(install-cpa):
	@make build-cpa-$(patsubst install-cpa-%,%,$@)
	@$(call install_cpa,$(patsubst install-cpa-%,%,$@))

check-deploy-dir:
	@$(call check_dir,${DEPLOY_DIR},DEPLOY_DIR)


install-klever: build-klever check-deploy-dir
	@echo "*** Installing ${klever} ***"
	@mkdir -p ${DEPLOY_DIR}/${install_dir}
	@rm -rf ${DEPLOY_DIR}/${klever_dir}
	@cp -r ${klever_dir} ${DEPLOY_DIR}/${klever_dir}
	@cp -r ${mea_lib} ${DEPLOY_DIR}/scripts/aux/mea.py

install-clade: check-deploy-dir
	@echo "*** Installing ${clade} into directory ${DEPLOY_DIR} ***"
	@$(call download_tool,${clade},${DEPLOY_DIR},${clade_repo})
	@rm -f ~/.local/lib/python*/site-packages/clade.egg-link
	@cd ${DEPLOY_DIR}; git checkout master; sudo python3 -m pip install -e .

install-benchexec: build-benchexec check-deploy-dir
	@echo "*** Installing ${benchexec} ***"
	@mkdir -p ${DEPLOY_DIR}/${install_dir}
	@rm -rf ${DEPLOY_DIR}/${benchexec_dir}
	@cp -r ${benchexec_dir} ${DEPLOY_DIR}/${benchexec_dir}

install-cil: build-cil check-deploy-dir
	@echo "*** Installing ${cil} ***"
	@mkdir -p ${DEPLOY_DIR}/${install_dir}
	@rm -rf ${DEPLOY_DIR}/${cil_dir}
	@cp -r ${cil_dir} ${DEPLOY_DIR}/${cil_dir}

install-astraver-cil: build-astraver-cil check-deploy-dir
	@echo "*** Installing ${astraver-cil} ***"
	@mkdir -p ${DEPLOY_DIR}/${install_dir}
	@rm -rf ${DEPLOY_DIR}/${astraver_cil_dir}
	@cp -r ${astraver_cil_dir} ${DEPLOY_DIR}/${astraver_cil_dir}

install-cif: build-cif check-deploy-dir
	@echo "*** Installing ${cif} ***"
	@mkdir -p ${DEPLOY_DIR}/${install_dir}
	@rm -rf ${DEPLOY_DIR}/${cif_dir}
	@cd ${cif_dir}; prefix=${DEPLOY_DIR}/${cif_dir} make install

install-cif-compiled: build-cif-compiled check-deploy-dir
	@echo "*** Installing compiled ${cif} ***"
	@mkdir -p ${DEPLOY_DIR}/${install_dir}
	@rm -rf ${DEPLOY_DIR}/${cif_dir}
	@cp -r ${cif_dir} ${DEPLOY_DIR}/${cif_dir}

install-scripts: check-deploy-dir
	@mkdir -p ${DEPLOY_DIR}
	@cd ${DEPLOY_DIR} ; \
	cp -r ${root_dir}/verifier_files/ . ; \
	cp -r ${root_dir}/patches/ . ; \
	cp -r ${root_dir}/rules/ . ; \
	cp -r ${root_dir}/entrypoints/ . ; \
	cp -r ${root_dir}/configs/ . ; \
	cp -r ${root_dir}/scripts/ . ; \
	cp -r ${root_dir}/plugin/ . ; \
	mkdir -p buildbot

install-witness-visualizer: check-deploy-dir build-klever
	@mkdir -p ${DEPLOY_DIR}/${install_dir}
	@rm -rf ${DEPLOY_DIR}/${klever_dir}
	@mkdir -p ${DEPLOY_DIR}/${klever_dir}
	@mkdir -p ${DEPLOY_DIR}/${klever_dir}/core/core/vrp/et/
	@cp ${klever_dir}/core/core/vrp/et/*.py ${DEPLOY_DIR}/${klever_dir}/core/core/vrp/et/
	@mkdir -p ${DEPLOY_DIR}/${klever_dir}/bridge/
	@mkdir -p ${DEPLOY_DIR}/${klever_dir}/bridge/templates/reports/
	@mkdir -p ${DEPLOY_DIR}/${klever_dir}/bridge/reports/
	@mkdir -p ${DEPLOY_DIR}/${klever_dir}/bridge/bridge/
	@mkdir -p ${DEPLOY_DIR}/${klever_dir}/bridge/media/
	@cp -r ${klever_dir}/bridge/static ${DEPLOY_DIR}/${klever_dir}/bridge/
	@cp ${klever_dir}/bridge/templates/base.html ${DEPLOY_DIR}/${klever_dir}/bridge/templates/
	@cp ${klever_dir}/bridge/reports/templates/reports/*.html ${DEPLOY_DIR}/${klever_dir}/bridge/templates/reports/
	@cp -r ${klever_dir}/bridge/reports/mea ${DEPLOY_DIR}/${klever_dir}/bridge/reports/
	@cp -r ${klever_dir}/bridge/reports/static ${DEPLOY_DIR}/${klever_dir}/bridge/reports/
	@cp ${klever_dir}/bridge/reports/etv.py ${DEPLOY_DIR}/${klever_dir}/bridge/reports/
	@cp ${klever_dir}/bridge/bridge/* ${DEPLOY_DIR}/${klever_dir}/bridge/bridge/
	@rm -rf ${DEPLOY_DIR}/${klever_dir}/bridge/static/codemirror
	@rm -rf ${DEPLOY_DIR}/${klever_dir}/bridge/static/calendar
	@rm -rf ${DEPLOY_DIR}/${klever_dir}/bridge/static/jstree
	@rm -rf ${DEPLOY_DIR}/${klever_dir}/bridge/static/js/population.js
	@cd ${DEPLOY_DIR} ; \
	cp -r ${root_dir}/scripts/ . ; \
	cp ${klever_dir}/bridge/reports/mea/core.py ${DEPLOY_DIR}/scripts/aux/mea.py
	@echo "*** Witness Visualizer has been successfully installed into the directory ${DEPLOY_DIR} ***"

install-benchmark-processor: install-witness-visualizer
	@cp -r ${klever_dir}/utils/ ${DEPLOY_DIR}/${klever_dir}/
	@cp ${klever_dir}/core/core/*.py ${DEPLOY_DIR}/${klever_dir}/core/core/

install: check-deploy-dir install-klever install-benchexec install-cil $(install-cpa) install-scripts
	@echo "*** Successfully installed into the directory ${DEPLOY_DIR}' ***"

install-with-cloud: check-deploy-dir install-klever install-benchexec install-cil install-cpa-with-cloud-links install-scripts
	@echo "*** Successfully installed into the directory ${DEPLOY_DIR}' with access to verification cloud ***"

install-cpa-with-cloud-links: | check-deploy-dir $(install-cpa)
	@$(call check_dir,${VCLOUD_DIR},"VCLOUD_DIR","is_exist")
	@for cpa in ${cpa_modes}; do \
		cd "${DEPLOY_DIR}/${install_dir}/$${cpa}" ; \
		mkdir -p lib/java-benchmark/ ; \
		cp ${VCLOUD_DIR}/vcloud.jar lib/java-benchmark/ ; \
	done
	@echo "*** Successfully created links for verification cloud in CPAchecker installation directories ***"

install-plugin:
	@$(call check_dir,${PLUGIN_DIR},"PLUGIN_DIR","is_exist")
	@$(call check_dir,${PLUGIN_ID},"PLUGIN_ID")
	@echo "*** Installing plugin '${PLUGIN_ID}' into directory '${plugin_dir}/${PLUGIN_ID}' ***"
	@if [ -d "${plugin_dir}/${PLUGIN_ID}" ]; then \
		echo "*** Removing old plugin installation '${plugin_dir}/${PLUGIN_ID}' ***" ; \
	fi
	@mkdir -p ${plugin_dir}/${PLUGIN_ID}
	@cp -r ${PLUGIN_DIR}/* ${plugin_dir}/${PLUGIN_ID}
	
delete-plugins:
	@echo "*** Removing all installed plugins ***"
	@rm -rf plugin/*

clean:
	@echo "*** Removing old installation ***"
	@rm -rf ${install_dir}
	@git checkout -- ${install_dir}/


# download_tool(name, path, repository)
define download_tool
	if [ -d "$2" ]; then \
		echo "*** Tool $1 is already downloaded in directory $2 ***" ; \
	else \
		echo "*** Downloading tool $1 into directory $2 ***" ; \
		git clone --recursive $3 $2 ; \
	fi
	cd $2; git fetch
endef

# $1 - directory name, $(word 1,$($1)) - branch, $(word 2,$($1)) - revision
define download_cpa
	if [ -d "${install_dir}/$1" ]; then \
		echo "*** CPAchecker mode $1 is already downloaded in directory ${install_dir}/$1 ***" ; \
	else \
		echo "*** Downloading CPAchecker branch $1 into directory ${install_dir}/$1 ***" ; \
		if [ $(word 1,$($1)) != 'trunk' ]; then \
			svn co ${cpa_branches_repo}/$(word 1,$($1)) ${install_dir}/$1; \
		else \
			svn co ${cpa_trunk_repo} ${install_dir}/$1; \
		fi ; \
	fi
	cd ${install_dir}/$1; svn cleanup; svn up -r $(word 2,$($1)); svn revert -R . ; \
	for patch in ../../patches/tools/cpachecker/$1.patch ../../plugin/*/patches/tools/cpachecker/$1.patch; do  \
		if [ -e "$${patch}" ]; then \
			echo "Applying patch '$${patch}'" ; \
			svn patch "$${patch}";\
		fi ; \
	done
endef

# $1 - branch
define build_cpa
	if [ -e "${install_dir}/$1/${cpa_arch}" ]; then \
		echo "*** CPAchecker branch $1 is already build in file ${install_dir}/$1/${cpa_arch} ***" ; \
	else \
		echo "*** Building CPAchecker branch $1 ***" ; \
		cd ${install_dir}/$1; ant build tar; mv CPAchecker-*.tar.bz2 ${cpa_arch} ; \
	fi
endef

# $1 - branch
define clean_cpa
	echo "*** Cleaning CPAchecker branch $1 ***"
	rm -rf ${install_dir}/$1/*; cd ${install_dir}/$1; svn revert -R .
endef

# $1 - branch
define install_cpa
	echo "*** Installing CPAchecker branch $1 ***"
	cd ${install_dir}/$1; \
	tar -xf ${cpa_arch} ; \
	mkdir -p ${DEPLOY_DIR}/${install_dir} ; \
	rm -rf ${DEPLOY_DIR}/${install_dir}/$1 ; \
	mv CPAchecker-*/ ${DEPLOY_DIR}/${install_dir}/$1
endef

# $1 - absolute directory path, $2 - env variable name, $3 - aux options
define check_dir
	if [ -n "$1" ]; then \
		if [ "$1" -ef "${root_dir}" ]; then \
			echo "Specified directory path '$1' is the same as current directory"; \
			false ; \
		else \
			if [ "$3" = "is_exist" ] ; then \
				if [ -d "$1" ] ; then \
					true ; \
				else \
					echo "Specified directory path '$1' does not exist. Add correct path to the '$2' environment variable"; \
					false; \
				fi ; \
			else \
				true ; \
			fi \
		fi ; \
	else \
		echo "Required variable '$2' was not specified"; \
		false; \
	fi
endef
