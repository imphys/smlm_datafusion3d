function progress_bar(n_iterations,iteration)

length = 20;

progress = floor(iteration * length / n_iterations);
previous_progress = floor((iteration-1) * length / n_iterations);

current_progress = progress - previous_progress;

if current_progress > 0
    for i=1:current_progress
        fprintf('|');
    end
end

end