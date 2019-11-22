classdef TestERD < matlab.unittest.TestCase
    % TestERD tests unusual ERD scenarios.
    methods (Test)
        function testDraw(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            package = 'University'

            c1 = dj.conn(...
                testCase.CONN_INFO.host,...
                testCase.CONN_INFO.user,...
                testCase.CONN_INFO.password,'',true);

            dj.createSchema(package,'test_schemas', [testCase.PREFIX '_university']);

            insert(University.Student, {
               0   'John'   'Smith'
               1   'Phil'   'Howard'
               2   'Ben'   'Goyle'
            });

            University.Student

            dj.ERD(University.Student)
            savefig('test.fig')

            % c1.query('SHOW DATABASES;')

            % dj.createSchema('new','Schema','test_schema')

            % schemaObject = dj.Schema(dj.conn, 'Schema', 'test_schema');



        end
    end
end