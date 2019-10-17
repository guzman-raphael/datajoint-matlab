classdef Main < ...
    tests.TestConnection & ...
    tests.TestERD & ...
    tests.TestTls

    properties (Constant)
        CONN_INFO_ROOT = struct(...
            'host', getenv('DJ_HOST'), ...
            'user', getenv('DJ_USER'), ...
            'password', getenv('DJ_PASS'));
        CONN_INFO = struct(...
            'host', getenv('DJ_TEST_HOST'), ...
            'user', getenv('DJ_TEST_USER'), ...
            'password', getenv('DJ_TEST_PASSWORD'));
        PREFIX = 'DjTest';
    end

    methods (TestClassSetup)
        function init(testCase)
            disp('---------------INIT---------------');
            clear functions;
            testCase.addTeardown(@testCase.dispose);
            
            curr_conn = dj.conn(testCase.CONN_INFO_ROOT.host, ...
                testCase.CONN_INFO_ROOT.user, testCase.CONN_INFO_ROOT.password,'',true);

            ver = curr_conn.query('select @@version as version').version;
            if dj.lib.compareVersions(ver,'5.8')
                cmd = {...
                'CREATE USER IF NOT EXISTS ''datajoint''@''%%'' '
                'IDENTIFIED BY ''datajoint'';'
                };
                curr_conn.query(sprintf('%s',cmd{:}));

                cmd = {...
                ['GRANT ALL PRIVILEGES ON `' testCase.PREFIX '%%`.* TO ''datajoint''@''%%'';']
                };
                curr_conn.query(sprintf('%s',cmd{:}));

                cmd = {...
                'CREATE USER IF NOT EXISTS ''djview''@''%%'' '
                'IDENTIFIED BY ''djview'';'
                };
                curr_conn.query(sprintf('%s',cmd{:}));

                cmd = {...
                ['GRANT SELECT ON `' testCase.PREFIX '%%`.* TO ''djview''@''%%'';']
                };
                curr_conn.query(sprintf('%s',cmd{:}));

                cmd = {...
                'CREATE USER IF NOT EXISTS ''djssl''@''%%'' '
                'IDENTIFIED BY ''djssl'' '
                'REQUIRE SSL;'
                };
                curr_conn.query(sprintf('%s',cmd{:}));

                cmd = {...
                ['GRANT SELECT ON `' testCase.PREFIX '%%`.* TO ''djssl''@''%%'';']
                };
                curr_conn.query(sprintf('%s',cmd{:}));
            else
                cmd = {...
                ['GRANT ALL PRIVILEGES ON `' testCase.PREFIX '%%`.* TO ''datajoint''@''%%'' ']
                'IDENTIFIED BY ''datajoint'';'
                };
                curr_conn.query(sprintf('%s',cmd{:}));

                cmd = {...
                ['GRANT SELECT ON `' testCase.PREFIX '%%`.* TO ''djview''@''%%'' ']
                'IDENTIFIED BY ''djview'';'
                };
                curr_conn.query(sprintf('%s',cmd{:}));

                cmd = {...
                ['GRANT SELECT ON `' testCase.PREFIX '%%`.* TO ''djssl''@''%%'' ']
                'IDENTIFIED BY ''djssl'' '
                'REQUIRE SSL;'
                };
                curr_conn.query(sprintf('%s',cmd{:}));
            end
        end
    end
       
    methods (Static)
        function dispose()
            disp('---------------DISP---------------');
            warning('off','MATLAB:RMDIR:RemovedFromPath');
            
            curr_conn = dj.conn(tests.Main.CONN_INFO_ROOT.host, ...
                tests.Main.CONN_INFO_ROOT.user, tests.Main.CONN_INFO_ROOT.password, '',true);

            res = curr_conn.query(['SHOW DATABASES LIKE "' tests.Main.PREFIX '_%";']);
            for i = 1:length(res.(['Database (' tests.Main.PREFIX '_%)']))
                curr_conn.query(['DROP DATABASE ' res.(['Database (' tests.Main.PREFIX '_%)']){i} ';']);
            end

            cmd = {...
            'DROP USER ''datajoint''@''%%'';'
            'DROP USER ''djview''@''%%'';'
            'DROP USER ''djssl''@''%%'';'
            };
            res = curr_conn.query(sprintf('%s',cmd{:}));
            curr_conn.delete;

            % Remove getSchemas to ensure they are created by tests.
            files = dir('test_schemas')
            dirFlags = [files.isdir] & ~strcmp({files.name},'.') & ~strcmp({files.name},'..')
            subFolders = files(dirFlags)
            for k = 1 : length(subFolders)
                delete(['test_schemas/' subFolders(k).name '/getSchema.m'])
                % delete(['test_schemas/+University/getSchema.m'])
            end
            warning('on','MATLAB:RMDIR:RemovedFromPath');
        end
    end
end
