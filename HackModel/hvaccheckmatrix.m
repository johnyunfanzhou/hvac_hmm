function hvaccheckmatrix(A, B, Sn, Hn, Wn, On)

    % check transition and emission matrix
    if ~isequal(size(A), [Sn * Hn * Wn * On, On])
        error('Invalid transition matrix dimension');
    elseif ~isequal(size(B), [Sn * Hn * Wn * On, 2])
        error('Invalid emission matrix dimension');
    end
end