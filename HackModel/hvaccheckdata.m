function hvaccheckdata(data, Sn, Hn, Wn)
    datasize = size(data, 1);

    % check if data is valid
    for i = 1 : datasize
        if data(i, 1) >= 2
            error('Invalid Occupancy state/observation.');
        elseif data(i, 2) >= Sn
            error('Invalid Season value.');
        elseif data(i, 3) >= Hn
            error('Invalid Hour value.');
        elseif data(i, 4) >= Wn
            error('Invalid Weekday/Weekend value.');
        else
            continue;
        end
    end
end
