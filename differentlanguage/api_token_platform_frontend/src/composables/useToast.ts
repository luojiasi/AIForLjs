import { ref } from 'vue'
import type { Toast, ToastType } from '@/types/common'

const toasts = ref<Toast[]>([])
let nextId = 0

export function useToast() {
  function addToast(type: ToastType, message: string, duration = 4000) {
    const id = String(++nextId)
    toasts.value.push({ id, type, message, duration })
    if (duration > 0) {
      setTimeout(() => removeToast(id), duration)
    }
  }

  function removeToast(id: string) {
    const idx = toasts.value.findIndex((t) => t.id === id)
    if (idx >= 0) toasts.value.splice(idx, 1)
  }

  function success(msg: string) {
    addToast('success', msg)
  }

  function error(msg: string) {
    addToast('error', msg, 6000)
  }

  function warning(msg: string) {
    addToast('warning', msg)
  }

  function info(msg: string) {
    addToast('info', msg)
  }

  return { toasts, addToast, removeToast, success, error, warning, info }
}
