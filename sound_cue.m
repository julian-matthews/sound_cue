%% CUE THE SOUND
% Created 2019-04-03: Julian Matthews & Stephen Gadsby
% A Cognition & Philosophy joint
%
% Hit a predefined key (default = SPACEBAR) to hear an auditory cue.
% Cue timing manipulated: either immediate or delayed (default = 5 seconds)
%
% Press LEFT-SHIFT key to exit function

function errorlog = sound_cue

% Wait time (in seconds)
cue_wait = 5;

% Probability of wait (number from 0 to 1)
cue_probability = 0.5;

% Display time of key press in Command Window (0= no display)
USE_echo = 1;

% Cue randomisation:
USE_randomisation = 1;

% If 1 then the RNG seed is reset on basis of current clock time
% If 0 then the RNG seed is set to a standardised value so the 'random'
% order will be the same each time the function is run. This might be
% preferred if you want to test the same set of trials over a large group
% of participants

%% RNG GENERATOR

if USE_randomisation
    
    % Check clock time and select hour, minute, and second values
    t = clock;
    RNG_seed = t(4)*t(5)*t(6);
    
else
    
    RNG_seed = 112358; %#ok<*UNRCH>
end

% Reset RNG on basis of specified seed
rng(RNG_seed,'twister')

%% LOAD SOUND

try
    % Find sound file and read sample data + sample rate
    [Y, Fs] = audioread('cued_sound.wav');
    
    % Load into sound object
    cue_sound = audioplayer(Y,Fs);
    
    %% PREPARE KEYBOARD
    
    % MATLAB's handling of keyboards can be clunky, if an external keyboard is
    % plugged in after MATLAB is opened it will occasionally fail to register.
    % This code will ensure all devices are checked but you can uncomment the
    % area below to specify a particular device for triggering cues
    
    device_num = -1;
    
    % clear PsychHID
    % devices = PsychHID('Devices');
    % for device = 1:length(devices)
    %     if strcmp(devices(device).usageName,'Keyboard') ...
    %             && contains(devices(device).product,'Internal')
    %         device_num = device;
    %         break
    %     elseif device == length(devices)
    %         device_num = -1;
    %     end
    % end
    
    % Standardise keyboard names across operating systems
    KbName('UnifyKeyNames')
    
    % Set the trigger key
    trigger_key = KbName('space');
    
    % Set the exit key
    exit_key = KbName('LeftShift');
    
    %% WAIT FOR KEYBOARD CUE OR ESCAPE
    
    % Enter while loop, function will continue to check for keyboard input
    % If ESC key is pressed the function will terminate
    
    try
        
        cue_count = 0;
        while 1
            
            % Check status of keyboard device
            [keyIsDown, ~, keyCode] = KbCheck(device_num);
            
            % Recognise that key has been pressed
            if keyIsDown
                
                if keyCode(trigger_key)
                    
                    cue_count = cue_count + 1;
                    stop(cue_sound);
                    
                    % Random integer from 1 to 100
                    wait_or_not = randi(100);
                    
                    if USE_echo
                        fprintf('Trigger %g detected at %s\n',cue_count,...
                            datestr(now,'HH.MM.SS.FFF'));
                    end
                    
                    if wait_or_not <= cue_probability*100
                        WaitSecs(cue_wait);
                    end
                    
                    if USE_echo
                        fprintf('Cue %g triggered at %s\n',cue_count,...
                            datestr(now,'HH.MM.SS.FFF'));
                    end
                    
                    play(cue_sound);
                    
                    % Slight delay so sound doesn't retrigger
                    WaitSecs(1);
                    
                elseif keyCode(exit_key)
                    
                    if USE_echo
                        fprintf('Exit triggered at %s\n',datestr(now,'HH.MM.SS.FFF'));
                    end
                    
                    break
                    
                end
            end
        end
        
    catch errorlog
        disp('Encountered error during play, probably keyboard problem but check error file')
    end
    
catch
    disp('Audio file not found, place file called `cued_sound.wav` in sound_cue folder');
    
end