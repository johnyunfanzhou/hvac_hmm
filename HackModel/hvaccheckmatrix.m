function hvaccheckmatrix(A, B, Sn, Hn, Wn)

    % check transition and emission matrix
    if ~isequal(size(A), [Sn * Hn * Wn * 2, 2])
        error('Invalid transition matrix dimension');
    elseif ~isequal(size(B), [Sn * Hn * Wn * 2, 2])
        error('Invalid emission matrix dimension');
    end
end