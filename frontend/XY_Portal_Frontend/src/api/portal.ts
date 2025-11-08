import request from '@/utils/request'

export interface PortalEntry {
  id?: number
  name: string
  description?: string
  icon?: string
  url: string
  category?: string
  status?: string
  sortOrder?: number
}

export const getEntries = (params?: { status?: string; category?: string; keyword?: string }) => {
  return request.get<PortalEntry[]>('/api/v1/portal/entries', { params })
}

export const getEntryById = (id: number) => {
  return request.get<PortalEntry>(`/api/v1/portal/entries/${id}`)
}

export const createEntry = (data: PortalEntry) => {
  return request.post<PortalEntry>('/api/v1/portal/entries', data)
}

export const updateEntry = (id: number, data: PortalEntry) => {
  return request.put<PortalEntry>(`/api/v1/portal/entries/${id}`, data)
}

export const deleteEntry = (id: number) => {
  return request.delete(`/api/v1/portal/entries/${id}`)
}

export const updateSortOrder = (entryIds: number[]) => {
  return request.put('/api/v1/portal/entries/sort', entryIds)
}

