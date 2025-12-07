// Servicios de datos
import { apiClient } from './client.js';

export const DataService = {
    // Services
    async getServices() {
        return await apiClient.get('/services/');
    },

    // Courses
    async getCourses() {
        return await apiClient.get('/courses/');
    },

    async getCourse(courseId) {
        return await apiClient.get(`/courses/${courseId}`);
    },

    async getUserCourseProgress() {
        return await apiClient.get('/courses/user/progress');
    },

    async updateCourseProgress(courseId, progress) {
        return await apiClient.post(`/courses/${courseId}/progress`, progress);
    },

    // Projects
    async getProjects() {
        return await apiClient.get('/projects/');
    },

    async createProject(project) {
        return await apiClient.post('/projects', project);
    },

    // Tools
    async getTools() {
        return await apiClient.get('/tools/');
    },

    // Dashboard
    async getDashboardStats() {
        return await apiClient.get('/dashboard/stats');
    },

    async getCampusSections() {
        return await apiClient.get('/dashboard/campus/sections');
    },

    // Contact
    async sendContactMessage(message) {
        return await apiClient.post('/contact/', message);
    },

    // Consultancy
    async sendConsultancyEmail(consultancyData) {
        return await apiClient.post('/consultancy/email/', consultancyData);
    }
};