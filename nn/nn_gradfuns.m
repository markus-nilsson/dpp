classdef nn_gradfuns

    methods (Static)

        function [loss, gradients, components] = mse(net, X, Y)

            YPred = forward(net, X);
            loss = mse(YPred, Y) / numel(Y);

            gradients = dlgradient(loss, net.Learnables);

            components = {loss};

        end

        function [loss, gradients, components] = mse_and_gradients(net, X, Y, alpha)
            % Forward pass
            YPred = forward(net, X);

            % Standard MSE loss
            loss_mse = mse(YPred, Y) / numel(Y);

            % Compute image gradients (simple finite differences)
            dx = @(I) I(:, [2:end end], :, :) - I;   % Gradient in x-direction
            dy = @(I) I([2:end end], :, :, :) - I;   % Gradient in y-direction

            % Compute gradient differences
            grad_YPred_x = dx(YPred);
            grad_YPred_y = dy(YPred);
            grad_Y_x     = dx(Y);
            grad_Y_y     = dy(Y);

            loss_grad = (mse(grad_YPred_x, grad_Y_x) + mse(grad_YPred_y, grad_Y_y)) / numel(Y);

            % Total loss: weighted sum
            % alpha = 0.3; % You can tune this
            loss = loss_mse + alpha * loss_grad;

            % Backpropagation
            gradients = dlgradient(loss, net.Learnables);

            % Report back individual components
            components = {loss_mse, loss_grad};            
        end

        function [loss, gradients, components] = dice_bce(net, X, Y)

            % Forward pass
            YPred = forward(net, X);

            % Ensure predictions are in [0,1]
            YPred = sigmoid(YPred);

            % Binary Cross-Entropy
            eps = 1e-6;
            BCE = -mean(Y .* log(YPred + eps) + (1 - Y) .* log(1 - YPred + eps), 'all');

            % Dice Loss
            intersection = sum(YPred .* Y, 'all');
            union = sum(YPred + Y, 'all');
            Dice = 1 - (2 * intersection + eps) / (union + eps);

            % Combined Loss
            loss = BCE + Dice;

            % Compute gradients
            gradients = dlgradient(loss, net.Learnables);

            % Optional components for logging
            components = {BCE, Dice, loss};

        end

        function [loss, gradients, components] = bce(net, X, Y)

            % Forward pass
            YPred = forward(net, X);

            % Y(:,:,2,:) = 1 - Y(:,:,1,:);

            % Combined Loss
            eps = 1e-6;
            loss = Y .* log(YPred + eps); % + (1 - Y) .* log(1 - YPred + eps);
            loss(:,:,1,:) = loss(:,:,1,:) * 4 / 128 / 128 / 20;
            loss = -mean(loss, [1 2 3 4]);

            % weight = sum(Y(:,:,1,:), [1 2 3]);
            % 
            % loss = weight .* loss;

            % loss = mean(loss, 'all');


            loss = loss * 1e3;

            % Compute gradients
            gradients = dlgradient(loss, net.Learnables);

            % Optional components for logging
            components = {loss};

        end

    end

end