/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipe.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: harleyng <harleyng@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/19 14:18:57 by harleyng          #+#    #+#             */
/*   Updated: 2025/06/11 21:00:22 by harleyng         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static bool	pipe_has_redirs(t_token *token)
{
	while (token != NULL)
	{
		if (token->type == APPEND || token->type == OUTPUT)
			return (true);
		token = token->next;
	}
	return (FALSE);
}

static void	exec_child_pipe_cmd(t_cmd_tbl *table, t_shell *shell, int fd_read,
		int fd_write)
{
	signals_child(&shell->mirror_termios);
	shell->print = TRUE;
	close(fd_read);
	dup2(fd_write, STDOUT_FILENO);
	close(fd_write);
	handle_redirections(shell, table);
	execute_command(table, shell);
}

static void	prepare_pipe_and_fork(t_cmd_tbl *table, t_shell *shell)
{
	pid_t	pid;
	int		status;
	int		fd[2];

	if (pipe(fd) == -1)
	{
		if (shell->print == TRUE)
			p_err("%s%s\n", SHELL, PIPE_ERROR);
	}
	pid = fork();
	shell->should_execute = TRUE;
	if (pid <= -1)
	{
		if (shell->print == TRUE)
			p_err("%s%s\n", SHELL, FORK_ERROR);
	}
	else if (pid == 0)
		exec_child_pipe_cmd(table, shell, fd[0], fd[1]);
	shell->print = FALSE;
	if (table->cmd != NULL)
		builtins(shell, table->cmd, table->cmd_args);
	close(fd[1]);
	dup2(fd[0], STDIN_FILENO);
	close(fd[0]);
}

static void	exec_last_pipe_cmd(t_cmd_tbl *table, t_shell *shell)
{
	pid_t	pid;
	int		status;
	int		fd[2];

	pid = fork();
	shell->should_execute = TRUE;
	if (pid == -1)
	{
		if (shell->print == TRUE)
			p_err("%s%s\n", SHELL, FORK_ERROR);
	}
	else if (pid == 0)
	{
		signals_child(&shell->mirror_termios);
		shell->print = TRUE;
		if (pipe_has_redirs(table->redirs) == FALSE)
			dup2(shell->std_fds[1], STDOUT_FILENO);
		handle_redirections(shell, table);
		execute_command(table, shell);
	}
	waitpid_to_get_exit_status(pid, shell, &status);
	if (table->cmd != NULL)
		builtins(shell, table->cmd, table->cmd_args);
	if (has_wrong_redir(shell, table->redirs, table) == FALSE)
		reset_io_streams(shell);
}

void	exec_pipes(t_cmd_tbl *table, t_shell *shell)
{
	int	status;
	int	pid;

	while (table->next != NULL)
	{
		prepare_pipe_and_fork(table, shell);
		table = table->next;
	}
	exec_last_pipe_cmd(table, shell);
	pid = waitpid(0, &status, 0);
	while (pid != -1)
		pid = waitpid(0, &status, 0);
}
