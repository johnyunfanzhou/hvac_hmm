function [smrPlot, falPlot, wtrPlot] = statePlot(data, state, Sn, Hn, Wn)
    % check valid inputs
    if Sn ~= 3
        error('Number of possible Season values has to be 3.');
    elseif Wn ~= 2
        error('Number of possible Weekday/Weekend values has to be 2.');
    end
    
    datasize = size(data, 1);
    
    hvaccheckdata(data, Sn, Hn, Wn);
    
    if size(state, 1) ~= datasize
        error('Length of state must match length of data.');
    end
    
    smrWday = zeros(Hn, 1);
    smrWend = zeros(Hn, 1);
    falWday = zeros(Hn, 1);
    falWend = zeros(Hn, 1);
    wtrWday = zeros(Hn, 1);
    wtrWend = zeros(Hn, 1);
    smrWdayN = zeros(Hn, 1);
    smrWendN = zeros(Hn, 1);
    falWdayN = zeros(Hn, 1);
    falWendN = zeros(Hn, 1);
    wtrWdayN = zeros(Hn, 1);
    wtrWendN = zeros(Hn, 1);

    for i = 1 : datasize
        switch (data(i, 2))
            case 0
                switch (data(i, 4))
                    case 0
                        smrWend(data(i, 3) + 1) = smrWend(data(i, 3) + 1) + state(i);
                        smrWendN(data(i, 3) + 1) = smrWendN(data(i, 3) + 1) + 1;
                    case 1
                        smrWday(data(i, 3) + 1) = smrWday(data(i, 3) + 1) + state(i);
                        smrWdayN(data(i, 3) + 1) = smrWdayN(data(i, 3) + 1) + 1;
                end
            case 1
                switch (data(i, 4))
                    case 0
                        falWend(data(i, 3) + 1) = falWend(data(i, 3) + 1) + state(i);
                        falWendN(data(i, 3) + 1) = falWendN(data(i, 3) + 1) + 1;
                    case 1
                        falWday(data(i, 3) + 1) = falWday(data(i, 3) + 1) + state(i);
                        falWdayN(data(i, 3) + 1) = falWdayN(data(i, 3) + 1) + 1;
                end
            case 2
                switch (data(i, 4))
                    case 0
                        wtrWend(data(i, 3) + 1) = wtrWend(data(i, 3) + 1) + state(i);
                        wtrWendN(data(i, 3) + 1) = wtrWendN(data(i, 3) + 1) + 1;
                    case 1
                        wtrWday(data(i, 3) + 1) = wtrWday(data(i, 3) + 1) + state(i);
                        wtrWdayN(data(i, 3) + 1) = wtrWdayN(data(i, 3) + 1) + 1;
                end
        end
    end

    smrWday = smrWday ./ smrWdayN;
    smrWend = smrWend ./ smrWendN;
    falWday = falWday ./ falWdayN;
    falWend = falWend ./ falWendN;
    wtrWday = wtrWday ./ wtrWdayN;
    wtrWend = wtrWend ./ wtrWendN;

    subplot(3, 1, 1);
    smrPlot = plot(0:47, smrWday, 'r', 0:47, smrWend, 'b');
    title('Probability of occupancy in Summer');
    legend('Weekdays', 'Weekends', 'Location', 'northeast');

    subplot(3, 1, 2);
    falPlot = plot(0:Hn-1, falWday, 'r', 0:Hn-1, falWend, 'b');
    title('Probability of occupancy in Fall/Spring');
    legend('Weekdays', 'Weekends', 'Location', 'northeast');

    subplot(3, 1, 3);
    wtrPlot = plot(0:Hn-1, wtrWday, 'r', 0:Hn-1, wtrWend, 'b');
    title('Probability of occupancy in Winter');
    legend('Weekdays', 'Weekends', 'Location', 'northeast');
end

