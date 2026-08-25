const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

// Test the My First Agent Starter functionality
async function testStarter() {
    console.log('=== Testing My First Agent - End-to-End Starter ===');
    
    try {
        // Test 1: Get starter guide
        console.log('\n1. Testing GET /starter/guide');
        let { stdout, stderr } = await execPromise('curl -s http://localhost:52773/api/starter/guide');
        if (stderr) throw new Error(stderr);
        let guide = JSON.parse(stdout);
        console.log(`   ✓ Received guide with ${guide.steps.length} steps`);
        
        // Test 2: Get templates
        console.log('\n2. Testing GET /starter/templates');
        ({ stdout, stderr } = await execPromise('curl -s http://localhost:52773/api/starter/templates'));
        if (stderr) throw new Error(stderr);
        let templates = JSON.parse(stdout);
        console.log(`   ✓ Received ${templates.length} templates`);
        
        // Test 3: Get specific template
        console.log('\n3. Testing GET /starter/templates/hello_world');
        ({ stdout, stderr } = await execPromise('curl -s http://localhost:52773/api/starter/templates/hello_world'));
        if (stderr) throw new Error(stderr);
        let template = JSON.parse(stdout);
        console.log(`   ✓ Received template: ${template.name}`);
        
        // Test 4: Get example conversation
        console.log('\n4. Testing GET /starter/conversation/hello_world');
        ({ stdout, stderr } = await execPromise('curl -s http://localhost:52773/api/starter/conversation/hello_world'));
        if (stderr) throw new Error(stderr);
        let conversation = JSON.parse(stdout);
        console.log(`   ✓ Received conversation with ${conversation.length} turns`);
        
        // Test 5: Create agent from template
        console.log('\n5. Testing POST /starter/create');
        const postData = {
            templateName: 'hello_world',
            agentName: 'Test Hello Agent',
            description: 'Test agent created via API'
        };
        
        ({ stdout, stderr } = await execPromise(
            `curl -s -X POST -H "Content-Type: application/json" -d '${JSON.stringify(postData)}' http://localhost:52773/api/starter/create`
        ));
        if (stderr) throw new Error(stderr);
        let result = JSON.parse(stdout);
        console.log(`   ✓ Created agent with ID: ${result.agentId}`);
        
        // Test 6: Verify agent was created
        console.log('\n6. Testing agent verification');
        ({ stdout, stderr } = await execPromise(`curl -s http://localhost:52773/api/agents/${result.agentId}`));
        if (stderr) throw new Error(stderr);
        let agent = JSON.parse(stdout);
        console.log(`   ✓ Verified agent: ${agent.AgentName}`);
        
        console.log('\n✅ All tests PASSED! My First Agent implementation is working correctly.');
        
    } catch (error) {
        console.error('\n❌ Test failed:', error.message);
        process.exit(1);
    }
}

testStarter();