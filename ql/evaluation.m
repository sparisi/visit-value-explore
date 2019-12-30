VC_history(totsteps) = sum(VC>0);

if mod(totsteps, 50) == 0

    if do_plot, mdp.pauseplot, end
    policy_eval.drawAction = @(s)egreedy( QT(mdp.get_state_idx(s),:)', 0 );
    J_history(end+1) = evaluate_policies(mdp, episodes_eval, steps_eval, policy_eval);
    if do_plot, mdp.resumeplot, end
end
