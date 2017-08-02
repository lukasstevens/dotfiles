builder=base16-builder
brightness=-b dark
name=my-base16
scheme=-s $(name).corrected.yml

.PHONY: all clean

all: $(name).sh $(name).vim $(name)-emacs

$(name)-emacs: $(name).corrected.yml
	$(builder) $(scheme) -t emacs $(brightness) > $(name)-emacs
$(name).sh: $(name).corrected.yml
	$(builder) $(scheme) -t shell $(brightness) > $(name).sh
$(name).vim: $(name).corrected.yml
	$(builder) $(scheme) -t vim $(brightness) > $(name).vim
$(name).corrected.yml: $(name).yml
	cat my-base16.yml | sed 's/\(#\)\([0-9a-fA-F]\{6\}\)/\2/g' > $(name).corrected.yml


clean:
	rm -rf $(name).sh $(name).vim $(name).corrected.yml
