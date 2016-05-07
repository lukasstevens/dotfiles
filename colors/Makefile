BUILDER=base16-builder
BRIGHTNESS=-b dark
SHELL_TEMPLATE=-t shell 
VIM_TEMPLATE=-t vim
NAME=my-base16
SCHEME=-s $(NAME).yml

all: $(NAME).sh $(NAME).vim

$(NAME).sh: $(NAME).yml
	$(BUILDER) $(SCHEME) $(SHELL_TEMPLATE) $(BRIGHTNESS) > $(NAME).sh
$(NAME).vim: $(NAME).yml
	$(BUILDER) $(SCHEME) $(VIM_TEMPLATE) $(BRIGHTNESS) > $(NAME).vim
