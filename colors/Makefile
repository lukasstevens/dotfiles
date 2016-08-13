BUILDER=base16-builder
BRIGHTNESS=-b dark
SHELL_TEMPLATE=-t shell 
VIM_TEMPLATE=-t vim
NAME=my-base16
SCHEME=-s $(NAME).corrected.yml

.PHONY: all clean

all: $(NAME).sh $(NAME).vim

$(NAME).sh: $(NAME).corrected.yml
	$(BUILDER) $(SCHEME) $(SHELL_TEMPLATE) $(BRIGHTNESS) > $(NAME).sh
$(NAME).vim: $(NAME).corrected.yml
	$(BUILDER) $(SCHEME) $(VIM_TEMPLATE) $(BRIGHTNESS) > $(NAME).vim
$(NAME).corrected.yml: $(NAME).yml
	cat my-base16.yml | sed 's/\(#\)\([0-9a-fA-F]\{6\}\)/\2/g' > $(NAME).corrected.yml


clean:
	rm -rf $(NAME).sh $(NAME).vim $(NAME).corrected.yml
