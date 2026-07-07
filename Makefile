CC				= cc
# SRC_DIR			= source/
MIN_DIR			= minishell_source/
EXE_DIR			= execution/
PAR_DIR			= parsing/
OBJ_DIR			= obj/
RM				= rm -rf
NAME			= minishell
DN				= > /dev/null
LIBFT			= libft/libft.a
OS				= $(shell uname)
USER			= $(shell whoami)
SLEEP			= $(shell sleep 2)
CFLAGS			= -Wall -Werror -Wextra
# INSTALL_READL	= $(shell brew install readline)

#DELETE THE PRINT FUNCTIONS FILE
MAIN			= main/prompt \
				  main/minishell \
				  main/shell_loop \
				  main/main_utils \

BUILTINS		= builtins/cd/cd \
				  builtins/env/env \
				  builtins/pwd/pwd \
				  builtins/exit/exit \
				  builtins/echo/echo \
				  builtins/unset/unset \
				  builtins/cd/cd_utils \
				  builtins/run_builtins \
				  builtins/cd/cd_options \
				  builtins/export/export \
				  builtins/env/env_utils \
				  builtins/exit/exit_utils \
				  builtins/exit/exit_helper \
				  builtins/echo/echo_utils \
				  builtins/unset/unset_utils \
				  builtins/export/empty_cont \
				  builtins/export/export_utils \

INIT 			= init/init \

LEXER			= lexer/lexer \
				  lexer/lexer_utils \
				  lexer/syntax_check \
				  lexer/syntax_utils \

PARSER			= parser/parser \
				  parser/token_utils \
				  parser/create_tokens \
				  parser/init_cmd_table \
				  parser/add_token_utils \
				  parser/cmd_table_utils \
				  parser/create_cmd_table \
				  parser/remove_quotes \

EXPANDER		= expander/expander \
				  expander/dont_expand \
				  expander/expand_tokens \
				  expander/expander_utils \
				  expander/expander_utils2 \

EXECUTOR		= executor/open/open \
				  executor/execute/execute \
				  executor/path/path_check \
				  executor/heredoc/here_doc \
				  executor/path/extract_path \
				  executor/pipe_handling/pipe \
				  executor/execute/execute_cmd \
				  executor/heredoc/open_heredoc \
				  executor/execute/execute_utils \
				  executor/heredoc/here_doc_utils \
				  executor/redirections/wrong_redirs \
				  executor/redirections/handle_redirs \
				  executor/execute/execute_without_pipes \
				  executor/pipe_handling/exec_only_heredoc \

SIGNALS			= signals/signals \
				  signals/signals_child \
				  signals/signals_parent \

CLEANUP_TOOLS	= cleanup_tools/free \

GENERAL_UTILS	= general_utils/error \
				  general_utils/general_utils \

SOURCE			= $(MAIN) $(INIT) $(SIGNALS) $(EXPANDER) $(LEXER) $(PARSER) \
				  $(EXECUTOR) $(BUILTINS) $(GENERAL_UTILS) $(CLEANUP_TOOLS) \




# SRC				= $(addprefix $(SRC_DIR), $(addsuffix .c, $(SOURCE)))
MIN				= $(addprefix $(MIN_DIR), $(addsuffix .c, $(SOURCE)))
EXE				= $(addprefix $(EXE_DIR), $(addsuffix .c, $(SOURCE)))
PAR				= $(addprefix $(PAR_DIR), $(addsuffix .c, $(SOURCE)))
SRC				= $(addprefix $(SRC_DIR), $(addsuffix .c, $(SOURCE)))
OBJ				= $(addprefix $(OBJ_DIR), $(addsuffix .o, $(SOURCE)))

ifeq ($(OS), Linux)
INCL_RDL_HEADER	= -I /home/linuxbrew/.linuxbrew/opt/readline/include/readline
INCL_RDL_LIB	= -lreadline -L /home/linuxbrew/.linuxbrew/opt/readline/lib
else
READLINE_PATH := $(shell brew --prefix readline)
INCL_RDL_HEADER = -I $(READLINE_PATH)/include
INCL_RDL_LIB = -L $(READLINE_PATH)/lib -lreadline
endif

BREW			= /Users/$(USER)/.brew/bin
READLINE		= /Users/$(USER)/.brew/opt/readline/include/readline

run: brew_check

brew_check:
	@if [ -d $(BREW) ]; then \
		echo "$(GREEN)BREW is already installed in $(BREW)$(DEF_COLOR)"; \
	else \
		{ \
			echo "$(YELLOW)Installing Homebrew...$(DEF_COLOR)"; \
			curl -fsSL https://rawgit.com/kube/42homebrew/master/install.sh | zsh; \
		}; \
	fi
	@$(MAKE) readline_check

readline_check:
	@if [ -d $(READLINE) ]; then \
		echo "$(GREEN)READLINE is already installed in $(READLINE)$(DEF_COLOR)"; \
	else \
		{ \
			echo "$(YELLOW)Installing Readline...$(DEF_COLOR)"; \
			$(INSTALL_READL) \
		}; \
	fi
	@$(MAKE) all


all: $(NAME)

$(NAME): $(LIBFT) $(OBJ)
	@$(CC) $(CFLAGS) -g -fsanitize=address $(OBJ) $(INCL_RDL_LIB) $(LIBFT) -o minishell $(DN)
	@cd obj/general_utils && touch user.txt && echo $$USER > user.txt

$(OBJ_DIR)%.o : $(EXE_DIR)%.c
	@mkdir -p $(@D)
	@$(CC) $(INCL_RDL_HEADER) -c $< -o $@ $(DN)

$(OBJ_DIR)%.o : $(PAR_DIR)%.c
	@mkdir -p $(@D)
	@$(CC) $(INCL_RDL_HEADER) -c $< -o $@ $(DN)

$(OBJ_DIR)%.o : $(MIN_DIR)%.c
	@mkdir -p $(@D)
	@$(CC) $(INCL_RDL_HEADER) -c $< -o $@ $(DN)

$(LIBFT):
	@echo "$(YELLOW)Compiling: $(DEF_COLOR)$(CYAN)LIBFT. $(DEF_COLOR)"
	@echo "$(CYAN2)" $(DN)
	@git submodule update --init --recursive --remote $(DN)
	@make -C ./libft $(DN)
	@echo "$(PURPLE)LIBFT $(DEF_COLOR)$(GREEN)has been compiled.$(DEF_COLOR)"

clean:
	@echo "$(CYAN)CLEAN$(DEF_COLOR)"
	@echo "$(RED)Deleting objects.$(DEF_COLOR)"
	@echo "$(CYAN2)" $(DN)
	@$(RM) $(OBJ_DIR) $(DN)
	@make clean -C ./libft $(DN)
	@echo "$(RED)Object files have been successfully removed!$(DEF_COLOR)"

fclean:
	@make clean $(DN)
	@echo "$(CYAN)FCLEAN$(DEF_COLOR)"
	@echo "$(RED)Deleting objects, executables.$(DEF_COLOR)"
	@echo "$(CYAN2)" $(DN)
	@$(RM) $(NAME) $(DN)
	@make fclean -C ./libft $(DN)
	@$(RM) minishell.dSYM $(DN)
	@echo "$(RED)Executable and object files have been successfully removed.$(DEF_COLOR)"

re: fclean all
	@echo "$(RED)Files have been cleaned and project has been rebuilt!$(DEF_COLOR)"

r:
	@./$(NAME)

DEF_COLOR = \033[0;39m
CYAN3 = \033[1;4;96m
YELLOW = \033[1;33m
PURPLE = \033[1;35m
BWhite = \033[1;37m
RED = \033[1;4;91m
GREEN = \033[4;92m
CYAN2 = \x1B[1;36m
CYAN = \033[1;96m

.PHONY: brew_check readline_check all clean fclean re run r v vm vf ne tester rt