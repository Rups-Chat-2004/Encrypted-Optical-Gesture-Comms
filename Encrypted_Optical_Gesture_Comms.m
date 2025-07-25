clc; clear;

% --- Test Mode from CSV ---
csvFiles = {'peace.csv', 'fist.csv', 'plam.csv'};
gesture_text = '';

for i = 1:length(csvFiles)
    if exist(csvFiles{i}, 'file')
        [~, name, ~] = fileparts(csvFiles{i});
        switch lower(name)
            case 'peace'
                gesture_text = 'PEACE';
            case 'fist'
                gesture_text = 'ATTACK';
            case 'plam'
                gesture_text = 'HOLD';
            otherwise
                gesture_text = '';
        end
        delete(csvFiles{i});
        break;
    end
end

if isempty(gesture_text)
    try
        camList = webcamlist;
        if isempty(camList)
            error('No webcam detected.');
        end
        cam = webcam(1);
        disp(['Using camera: ', cam.Name]);

        figure('Name', 'Show Gesture Inside Green Box', 'NumberTitle', 'off');
        frame = snapshot(cam);
        hImg = imshow(frame);

        % Define rectangle size and position
        boxWidth = 250;
        boxHeight = 250;
        cx = size(frame, 2) / 2;
        cy = size(frame, 1) / 2;
        rectPos = [cx - boxWidth/2, cy - boxHeight/2, boxWidth, boxHeight];
        hold on;
        hRect = rectangle('Position', rectPos, 'EdgeColor', 'g', 'LineWidth', 2);

        % Live preview with green rectangle overlay
        disp('Get ready... showing preview for 5 seconds...');
        tic;
        while toc < 15
            
            frame = snapshot(cam);
            set(hImg, 'CData', frame);
            drawnow;
        end

        % Final capture and crop
        img = snapshot(cam);
        img = imcrop(img, rectPos);
        close(gcf); clear cam;

        if isempty(img)
            error('Image capture failed.');
        end

        figure, imshow(img); title('Cropped Gesture Image');

    catch ME
        disp(['Webcam error: ', ME.message]);
        return;
    end

    % --- Skin Detection Using YCbCr ---
    ycbcr = rgb2ycbcr(img);
    Cb = ycbcr(:,:,2); Cr = ycbcr(:,:,3);
    skinMask = (Cb >= 77 & Cb <= 127) & (Cr >= 133 & Cr <= 173);

    bw = bwareaopen(skinMask, 2000);
    figure, imshow(bw); title('Skin Segmented Binary Image');

    % --- Gesture Recognition ---
    stats = regionprops(bw, 'Area', 'Eccentricity', 'BoundingBox');
    gesture_text = 'UNKNOWN';

    if ~isempty(stats)
        [~, idx] = max([stats.Area]);
        biggest = stats(idx);
        figure, imshow(bw); title('Detected Region');
        rectangle('Position', biggest.BoundingBox, 'EdgeColor', 'y', 'LineWidth', 2);

        area = biggest.Area;
        ecc = biggest.Eccentricity;

        fprintf('Detected Area: %.2f\n', area);
        fprintf('Detected Eccentricity: %.2f\n', ecc);

        if area > 6000 && ecc < 0.6
            gesture_text = 'HOLD';
        elseif area > 3000 && ecc > 0.7
            gesture_text = 'PEACE';
        elseif area > 2500 && ecc < 0.9
            gesture_text = 'ATTACK';
        else
            gesture_text = 'UNKNOWN';
        end
    end
else
    disp(['Recognized Gesture (from CSV): ', gesture_text]);
end

disp(['Recognized Gesture: ', gesture_text]);

% STEP 5: Message assignment
switch gesture_text
    case 'PEACE'
        message = 'PEACE';
    case 'HOLD'
        message = 'HOLD';
    case 'ATTACK'
        message = 'ATTACK';
    otherwise
        disp('No valid gesture detected. Transmission aborted.');
        return;
end

% STEP 6: AES-256 Encryption
keyString = 'ThisIsA256bitKeyThisIsA256bitKey';
keyBytes = uint8(keyString);
messageBytes = uint8(message);

disp(['Original Message: ', message]);
plainBits = reshape(dec2bin(messageBytes, 8).' - '0', 1, []);
disp('Plaintext Bitstream:');
disp(plainBits);

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

keySpec = SecretKeySpec(keyBytes, 'AES');
cipher = Cipher.getInstance('AES/ECB/PKCS5Padding');
cipher.init(Cipher.ENCRYPT_MODE, keySpec);
cipherText = cipher.doFinal(messageBytes);

cipherBits = reshape(dec2bin(typecast(cipherText, 'uint8'), 8).' - '0', 1, []);
disp('Encrypted Bitstream (AES-256):');
disp(cipherBits);

% STEP 7: FSO Intensity Modulation
bitStream = cipherBits;
fs = 10000;
f = 1000;
Tb = 1/1000;
t = 0:1/fs:Tb;
modulatedSignal = [];

for i = 1:length(bitStream)
    if bitStream(i) == 1
        modBit = sin(2*pi*f*t);
    else
        modBit = 0*t;
    end
    modulatedSignal = [modulatedSignal modBit]; %#ok<AGROW>
end

% STEP 8: Plot first 10 bits of modulated signal
num_bits_to_plot = 10;
samples_per_bit = length(t);
end_index = num_bits_to_plot * samples_per_bit;
partialSignal = modulatedSignal(1:end_index);
timeVector = (0:length(partialSignal)-1) / fs;

figure;
plot(timeVector, partialSignal, 'b');
title('FSO Intensity Modulated Signal (First 10 Bits)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on; ylim([-1.2, 1.2]);
hold on;
for i = 1:num_bits_to_plot
    x = (i-1)*samples_per_bit / fs;
    xline(x, '--k');
    text(x + 0.0002, 1, sprintf('%d', bitStream(i)), 'FontSize', 10, 'Color', 'r', 'FontWeight', 'bold');
end

% STEP 9: FSO Demodulation
num_bits = length(modulatedSignal) / samples_per_bit;
received_bits = zeros(1, num_bits);

for i = 1:num_bits
    segment = modulatedSignal((i-1)*samples_per_bit + 1 : i*samples_per_bit);
    if sum(abs(segment)) > 0.5 * samples_per_bit
        received_bits(i) = 1;
    else
        received_bits(i) = 0;
    end
end

disp('Received Bitstream:');
disp(received_bits);

% STEP 10: Decrypt received message
binStrs = reshape(char(received_bits + '0'), 8, []).';
byteArray = uint8(bin2dec(binStrs));
cipher.init(Cipher.DECRYPT_MODE, keySpec);
recoveredMessage = char(cipher.doFinal(byteArray)');

disp(['Recovered Message after FSO Transmission: ', recoveredMessage]);