function setupDJ(skipPathAddition, force)

    if nargin < 2
        force = false;
    end

    persistent INVOKED;
    
    if ~isempty(INVOKED) && ~force
        return
    end

    base = fileparts(mfilename('fullpath'));

    if nargin < 1
        skipPathAddition = false;
    end
    
    if ~skipPathAddition
        fprintf('Adding DataJoint to the path...\n')
        addpath(base)
    end

    mymdir = fullfile(base, 'mym');
    % if mym directory missing, download and install
    if ~isdir(mymdir)
        fprintf('mym missing. Downloading...\n')
        tic
        % project = 'guzman-raphael/mym';
        % branch = 'binary-fix';
        % dist_objs = webread(['https://api.github.com/repos/' project ...
        %     '/contents/distribution/' mexext() '?ref=' branch]);
        % mym_setup_obj = webread(['https://api.github.com/repos/' project ...
        %     '/contents/mymSetup.m?ref=' branch]);
        % mym_setup_obj = rmfield(mym_setup_obj, 'content');
        % mym_setup_obj = rmfield(mym_setup_obj, 'encoding');
        % dist_objs(end+1) = mym_setup_obj;
        % for i = 1:length(dist_objs)
        %     target = split(dist_objs(i).download_url, [project '/' branch]);
        %     filepath_cell = split(target{2}, '/');
        %     filepath_cell{1} = 'mym';
        %     fpath = base;
        %     for j = 1:length(filepath_cell)-1
        %         fpath = fullfile(fpath, filepath_cell(j));
        %         if ~exist(fpath{1}, 'dir')
        %             mkdir(fpath{1});
        %         end
        %     end
        %     fpath = fullfile(fpath, filepath_cell(end));
        %     websave(fpath{1}, dist_objs(i).download_url);
        % end
        
        target = fullfile(base, 'mym.zip');
        % mymURL = 'https://github.com/datajoint/mym/archive/master.zip';
        mymURL = 'https://github.com/guzman-raphael/mym/archive/binary-fix.zip';
        target = websave(target, mymURL);
        if isunix && ~ismac
            % on Linux Matlab unzip doesn't work properly so use system unzip
            system(sprintf('unzip -o %s -d %s', target, base))
        else
            unzip(target, base)
        end
        % rename extracted mym-master directory to mym
        % movefile(fullfile(base, 'mym-master'), mymdir)
        movefile(fullfile(base, 'mym-binary-fix'), mymdir)
        delete(target)
        toc
    end
    
    % run mymSetup.m
    fprintf('Setting up mym...\n')
    run(fullfile(mymdir, 'mymSetup.m'))
    
    INVOKED = 1;
end
