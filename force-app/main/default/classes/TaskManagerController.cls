public with sharing class TaskManagerController {
    @AuraEnabled(cacheable=true)
    public static List<Task> getUserTasks() {
        return [SELECT Id, Subject, Status, ActivityDate FROM Task WHERE OwnerId = :UserInfo.getUserId() ORDER BY ActivityDate ASC];
    }

    @AuraEnabled
    public static void updateTaskStatus(Id taskId, String status) {
        Task task = [SELECT Id, Status FROM Task WHERE Id = :taskId LIMIT 1];
        task.Status = status;
        update task;
    }

    @AuraEnabled
    public static Id createTask(String subject, Date dueDate, String priority) {
        Task newTask = new Task(
            Subject = subject,
            ActivityDate = dueDate,
            Priority = priority,
            OwnerId = UserInfo.getUserId()
        );
        insert newTask;
        return newTask.Id;
    }
}