classdef TestUuid < tests.Prep
    % TestERD tests unusual ERD scenarios.
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

            % insert(University.Student, {
            %    0   'John'   'Smith'
            %    1   'Phil'   'Howard'
            %    2   'Ben'   'Goyle'
            % });
            % insert(University.Message, struct('student_id',1,'msg_id','1d751e2e-1e74-faf8-4ab4-85fde8ef72be','body','Great campus!'));
            test_val = '1d751e2e-1e74-faf8-4ab4-85fde8ef72be';
            insert(University.Message, struct('msg_id',test_val,'body','Great campus!'));

            q = University.Message
            % q = University.Message & (University.Student & 'first_name="Phil"')

            res = q.fetch('msg_id');
            
            res.msg_id = reshape(lower(dec2hex(uint8(res.msg_id)))',1,[]);

            testCase.verifyEqual(res.msg_id,  strrep(test_val, '-', ''));
        end
    end
end