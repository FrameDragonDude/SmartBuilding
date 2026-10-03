const apiUrl = 'http://localhost:5169/api'

export type Resident = { apartmentId: string; apartmentNumber: string; apartmentStatus: string; residentId: string | null; fullName: string | null; phoneNumber: string | null; email: string | null; contractType: string | null }
export type Parking = { slotId: string; slotCode: string; basementLevel: string; slotType: string; isOccupied: boolean; vehicleId: string | null; vehicleType: string | null; licensePlate: string | null; rfidCardCode: string | null; brand: string | null; fullName: string | null; phoneNumber: string | null; apartmentNumber: string | null }

export async function getResidents(search = ''): Promise<Resident[]> { const result = await fetch(`${apiUrl}/residents?search=${encodeURIComponent(search)}`); if (!result.ok) throw new Error('Không thể tải dữ liệu cư dân'); return result.json() }
export async function getParking(search = ''): Promise<Parking[]> { const result = await fetch(`${apiUrl}/parking?search=${encodeURIComponent(search)}`); if (!result.ok) throw new Error('Không thể tải dữ liệu bãi xe'); return result.json() }
