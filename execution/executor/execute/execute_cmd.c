/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   execute_cmd.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: harleyng <harleyng@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/19 14:17:52 by harleyng          #+#    #+#             */
/*   Updated: 2025/06/11 20:32:45 by harleyng         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static void	exit_after_builtin(t_shell *shell)
{
	int	exit_code;

	exit_code = shell->exit_code;
	free_at_exit(shell);
	exit(exit_code);
}

static bool	is_a_directory(t_shell *shell, char *cmd)
{
	int	i;
	int	len;

	i = 0;
	len = ft_strlen(cmd);
	if (cmd[0] == '/' && cmd[len - 1] == '/')
	{
		if (shell->print == TRUE)
			p_err("%s%s: %s\n", SHELL, cmd, ISDIR);
		shell->exit_code = 126;
		return (TRUE);
	}
	return (FALSE);
}

static void	exec_command_with_env(char *cmd_path, t_cmd_tbl *table,
		t_shell *shell)
{
	char	**cmd_args;
	char	**env;
	int		exit_code;

	if (is_a_directory(shell, table->cmd) == TRUE)
		child_exit(shell);
	exit_code = shell->exit_code;
	shell->cmd_has_been_executed = 1;
	cmd_args = duplicate_string_array(table->cmd_args);
	env = duplicate_string_array(shell->env);
	if (execve(cmd_path, cmd_args, env) == -1)
	{
		if (shell->print == TRUE)
			p_err("%s%s\n", SHELL, strerror(errno));
		free(cmd_path);
		free_char_array(cmd_args);
		free_char_array(env);
		exit(exit_code);
	}
}

void	execute_command(t_cmd_tbl *table, t_shell *shell)
{
	char	*cmd_path;

	if (table->cmd == NULL)
		child_exit(shell);
	if (builtins(shell, table->cmd, table->cmd_args) == TRUE)
		exit_after_builtin(shell);
	else if (path_check(table->cmd, shell) == TRUE)
		exec_command_with_env(table->cmd, table, shell);
	else if (table->cmd[0] != '.' && table->cmd[0] != '/')
	{
		cmd_path = extract_path(shell, table->cmd);
		if (cmd_path == NULL)
			clear_and_exit(shell, cmd_path, table);
		else if (access(cmd_path, X_OK) == 0)
			exec_command_with_env(cmd_path, table, shell);
	}
}

void	child_exit(t_shell *shell)
{
	int	code;

	code = shell->exit_code;
	free_at_exit(shell);
	exit(code);
}
