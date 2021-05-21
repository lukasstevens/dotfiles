builder=base16-builder
brightness=-b dark
name=my-base16
scheme=-s $(name).corrected.yml
targets= $(name).sh $(name).vim $(name)-dark-theme.el

.PHONY: all clean

all: $(targets)
$(name)-dark-theme.el: $(name).corrected.yml
	$(builder) $(scheme) -t emacs $(brightness) | tail -n +5 - > base16-$(name)-dark-theme.el
$(name).sh: $(name).corrected.yml
	$(builder) $(scheme) -t shell $(brightness) > $(name).sh
$(name).vim: $(name).corrected.yml
	$(builder) $(scheme) -t vim $(brightness) > $(name).vim
$(name).corrected.yml: $(name).yml
	cat my-base16.yml | sed 's/\(#\)\([0-9a-fA-F]\{6\}\)/\2/g' > $(name).corrected.yml


clean:
	rm -rf $(targets) 
