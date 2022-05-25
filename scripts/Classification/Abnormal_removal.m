function [smoothed_pred,window] = Abnormal_removal(pred,n_break)
pred = double(pred);
smoothed_pred = zeros(size(pred));
window = 10;
cond =1;
start = pred(1:30);
start = start(start == 1);
if length(start) <5
    n_break = n_break-1;
end

while cond == 1
    for i=1:length(pred)
        if i<= window
            log1= pred(1:i-1) == pred(i);
	    if i+window <= length(pred)
            	    log2 = pred(i+1:i+window) == pred(i);
	    else 
		    log2 = pred(i+1:end);
	    end
            d_l = i-1;
            d_u = window;
        elseif (length(pred)-i)<=window
            log1 = pred(i-window:i-1) == pred(i);
            log2 = pred(i+1:end) == pred(i);
            d_u = length(pred) - i;
            d_l = window;
        else
            log1 = pred(i-window:i-1) == pred(i);
            log2 = pred(i+1:i+window) == pred(i);
            d_u = window;
            d_l = window;
        end
        if all(log1) || all(log2)
            smoothed_pred(i) = pred(i);
        else
            smoothed_pred(i) = mode(pred(i-d_l:i+d_u));
        end
        
    end
    breakpoint = 0;
    for i=2:length(smoothed_pred)
        if smoothed_pred(i) ~= smoothed_pred(i-1)
            breakpoint = breakpoint +1;
        end
    end
    if breakpoint>n_break
        window = window +2;
    else
        cond = 0;
    end
end
end
