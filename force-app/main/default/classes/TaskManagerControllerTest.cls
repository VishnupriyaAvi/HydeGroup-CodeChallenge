@IsTest
public class TaskManagerControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create sample Task records assigned to the running user
        List<Task> tasks = new List<Task>();
        for (Integer i = 1; i <= 5; i++) {
            tasks.add(new Task(
                Subject = 'Task ' + i,
                Status = 'Not Started',
                ActivityDate = Date.today().addDays(i),
                OwnerId = UserInfo.getUserId()
            ));
        }
        insert tasks;
    }

    @IsTest
    static void testGetUserTasks() {
        // Test the getUserTasks method
        List<Task> userTasks = TaskManagerController.getUserTasks();
        
        // Assert that the number of tasks returned matches the number of inserted tasks
        System.assertEquals(5, userTasks.size(), 'Expected 5 tasks to be returned');
        
        // Assert that the tasks are ordered by ActivityDate
        for (Integer i = 0; i < userTasks.size() - 1; i++) {
            System.assert(userTasks[i].ActivityDate <= userTasks[i+1].ActivityDate, 
                'Tasks should be ordered by ActivityDate in ascending order');
        }
    }

    @IsTest
    static void testUpdateTaskStatus() {
        // Get a task Id to update
        Id taskId = [SELECT Id FROM Task LIMIT 1].Id;

        // Call the updateTaskStatus method to update the task status
        TaskManagerController.updateTaskStatus(taskId, 'Completed');

        // Verify that the task status was updated
        Task updatedTask = [SELECT Status FROM Task WHERE Id = :taskId];
        System.assertEquals('Completed', updatedTask.Status, 'Task status should be updated to Completed');
    }

    @IsTest
    static void testCreateTask() {
        // Call the createTask method to create a new task
        Id newTaskId = TaskManagerController.createTask('New Task', Date.today().addDays(7), 'High');

        // Verify that the task was created successfully
        Task newTask = [SELECT Subject, ActivityDate, Priority, OwnerId FROM Task WHERE Id = :newTaskId];
        System.assertEquals('New Task', newTask.Subject, 'Subject should match the input value');
        System.assertEquals(Date.today().addDays(7), newTask.ActivityDate, 'ActivityDate should match the input value');
        System.assertEquals('High', newTask.Priority, 'Priority should match the input value');
        System.assertEquals(UserInfo.getUserId(), newTask.OwnerId, 'OwnerId should be the current user');
    }
}