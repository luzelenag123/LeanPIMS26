CHAPTER_DIR := ../LeanPIMS26
MD_DIR := src

LEAN_DIRS := $(wildcard $(CHAPTER_DIR)/*)
MD_DIRS :=  $(patsubst $(CHAPTER_DIR)/%,$(MD_DIR)/%,$(LEAN_DIRS))

LEAN_FILES := $(wildcard $(CHAPTER_DIR)/*/*.lean)
MD_FILES := $(patsubst $(CHAPTER_DIR)/%.lean,$(MD_DIR)/%.md,$(LEAN_FILES))

all: dirs $(MD_FILES)

$(MD_DIR)/%.md: $(CHAPTER_DIR)/%.lean 
	python3 dm.py $(CHAPTER_DIR)/$*.lean > $@	

dirs: $(MD_DIRS)

$(MD_DIRS):
	echo $@
	mkdir -p $@

show: 
	echo $(MD_DIRS)
	echo $(MD_FILES)

deploy: all
	rsync -a --delete $(MD_DIR)/ slider/src/
	bash slider/deploy.sh


clean:
	rm -r $(MD_DIR)/*

