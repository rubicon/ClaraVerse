import { apiClient } from '@/lib/apiClient';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001';

export interface SystemModelAssignments {
  tool_selector: string;
  memory_extractor: string;
  title_generator: string;
  workflow_validator: string;
  agent_default: string;
}

/**
 * Fetch current system model assignments
 */
export async function fetchSystemModelAssignments(): Promise<SystemModelAssignments> {
  const response = await apiClient.get(`${API_BASE_URL}/api/admin/system-models`, {
    requiresAuth: true,
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch system model assignments: ${response.statusText}`);
  }

  return await response.json();
}

/**
 * Update system model assignments
 */
export async function updateSystemModelAssignments(
  assignments: SystemModelAssignments
): Promise<void> {
  const response = await apiClient.put(
    `${API_BASE_URL}/api/admin/system-models`,
    assignments,
    { requiresAuth: true }
  );

  if (!response.ok) {
    throw new Error(`Failed to update system model assignments: ${response.statusText}`);
  }
}
