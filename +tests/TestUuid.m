classdef TestUuid < tests.Prep
    % TestUuid tests uuid scenarios.
    methods (Test)
        function testInsertFetch(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            package = 'University';

            c1 = dj.conn(...
                testCase.CONN_INFO.host,... 
                testCase.CONN_INFO.user,...
                testCase.CONN_INFO.password,'',true);

            dj.createSchema(package,[testCase.test_root '/test_schemas'], [testCase.PREFIX '_university']);

            test_val1 = '1d751e2e-1e74-faf8-4ab4-85fde8ef72be';
            insert(University.Message, struct( ...
                'msg_id', test_val1, ...
                'body', 'Great campus!' ...
            ));

            test_val2 = '12321346-1312-4123-1234-312739283795';
            insert(University.Message, struct( ...
                'msg_id', test_val2, ...
                'body', 'Great campus!' ...
            ));

            q = University.Message
            res = q.fetch('msg_id');
            value_check = res(1).msg_id;

            testCase.verifyEqual(value_check,  test_val2);
        end
        function testQuery(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            package = 'University';

            c1 = dj.conn(...
                testCase.CONN_INFO.host,... 
                testCase.CONN_INFO.user,...
                testCase.CONN_INFO.password,'',true);

            test_val = '1d751e2e-1e74-faf8-4ab4-85fde8ef72be';

            q = University.Message & 'msg_id="1d751e2e-1e74-faf8-4ab4-85fde8ef72be"'
            res = q.fetch('msg_id');
            value_check = res(1).msg_id;

            testCase.verifyEqual(value_check,  test_val);
        end
        function testReverseEngineering(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            
        end
        function testProjection(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            
        end
    end
end