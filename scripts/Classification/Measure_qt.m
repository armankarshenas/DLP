function [Measure_table] = measure_qt(Measure_table,pred_proc,n_break)
counter=1;
break_vec = zeros(1,n_break);
start = pred_proc(1:30);
start = start(start==1);
if length(start) < 10
    break_vec(1) = 1;
    counter = 2;
end
end_v = pred_proc(end-30:end);
end_v = end_v(end_v ==1);
if length(end_v) < 10
    break_vec(end) = length(pred_proc);
    n_break = n_break-1;
end
h = height(Measure_table);
for i=2:length(pred_proc)
    if pred_proc(i-1) ~= pred_proc(i) 
        if counter<= n_break
        break_vec(counter) = i;
        counter = counter +1;
        else 
            Measure_table{h,4} = "Not a clear boundary";
            return
        end
    end
end
counter=4;
for i=1:length(break_vec)
    for j=i+1:length(break_vec)
        Measure_table{h,counter} = break_vec(j) - break_vec(i);
        counter = counter + 1;
    end
end
end