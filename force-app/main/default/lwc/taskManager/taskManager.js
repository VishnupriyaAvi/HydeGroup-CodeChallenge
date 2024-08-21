import { LightningElement, wire, track } from 'lwc';
import getUserTasks from '@salesforce/apex/TaskManagerController.getUserTasks';
import updateTaskStatus from '@salesforce/apex/TaskManagerController.updateTaskStatus';
import createTask from '@salesforce/apex/TaskManagerController.createTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class TaskManager extends LightningElement {
    @track tasks;
    @track allTasks;
    @track draftValues = [];
    @track showModal = false;
    @track subject = '';
    @track dueDate = '';
    @track priority = '';
    @track currentPage = 1;
    @track pageSize = 3;  
    @track totalPages;
    priorityOptions = [
        { label: 'High', value: 'High' },
        { label: 'Normal', value: 'Normal' },
        { label: 'Low', value: 'Low' },
    ];
    columns = [
        { label: 'Subject', fieldName: 'Subject' },
        { label: 'Due Date', fieldName: 'ActivityDate', type: 'date' },
        { label: 'Status', fieldName: 'Status', editable: true },
        {
            type: 'button',
            typeAttributes: {
                label: 'Mark as Completed',
                name: 'completeTask',
                title: 'Mark as Completed',
                disabled: { fieldName: 'completed' },
                value: 'complete',
                iconPosition: 'left',
            },
        },
    ];
    @wire(getUserTasks)
    wiredTasks({ error, data }) {
        if (data) {
            this.allTasks = data.map(task => ({
                ...task,
                completed: task.Status === 'Completed',
            }));
            this.totalPages = Math.ceil(this.allTasks.length / this.pageSize);
            this.updateTasks();
        } else if (error) {
            this.allTasks = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading tasks',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }
    updateTasks() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        this.tasks = this.allTasks.slice(start, end);
    }
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updateTasks();
        }
    }
    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateTasks();
        }
    }
    get isPrevDisabled() {
        return this.currentPage === 1;
    }
    // Computed property for disabling the "Next" button
    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }
    handleSave(event) {
        const draftValues = event.detail.draftValues;
        const updatePromises = draftValues.map(draft => {
            if (draft.Id && draft.Status) {
                return updateTaskStatus({ taskId: draft.Id, status: draft.Status });
            } else {
                return Promise.reject(new Error('Invalid task data'));
            }
        });
        Promise.all(updatePromises)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Tasks updated',
                        variant: 'success',
                    })
                );
                return refreshApex(this.wiredTasksResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating tasks',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'completeTask') {
            updateTaskStatus({ taskId: row.Id, status: 'Completed' })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Task Completed',
                            message: 'Task is completed',
                            variant: 'success',
                        })
                    );
                    return refreshApex(this.wiredTasksResult);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error completing task',
                            message: error.body.message,
                            variant: 'error',
                        })
                    );
                });
        }
    }
    openCreateTaskModal() {
        this.showModal = true;
    }
    closeModal() {
        this.showModal = false;
    }
    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'subject') {
            this.subject = event.target.value;
        } else if (field === 'dueDate') {
            this.dueDate = event.target.value;
        } else if (field === 'priority') {
            this.priority = event.target.value;
        }
    }
    saveTask() {
        createTask({ subject: this.subject, dueDate: this.dueDate, priority: this.priority })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Task created successfully',
                        variant: 'success',
                    }),
                );
                this.closeModal();
                return refreshApex(this.wiredTasksResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating task',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
}