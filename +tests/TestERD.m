classdef TestERD < tests.Prep
    % TestERD tests unusual ERD scenarios.
    methods (Test)
        function testDraw(testCase)
            st = dbstack;
            disp(['---------------' st(1).name '---------------']);
            package = 'University';

            % addpath(['/src/+tests/test_schemas/+' package]);
            addpath('/src/+tests/test_schemas');
            c1 = dj.conn(...
                testCase.CONN_INFO.host,...
                testCase.CONN_INFO.user,...
                testCase.CONN_INFO.password,'',true);

            dj.createSchema(package,'/src/+tests/test_schemas', [testCase.PREFIX '_university']);

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

            % rmpath(['/src/test_schemas/+' package]);
            rmpath('/src/+tests/test_schemas');
        end
    end
end