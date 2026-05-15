import { ref } from 'vue'

export function useModal() {
  const isOpen = ref(false)
  const data = ref<unknown>(null)

  function open(payload?: unknown) {
    data.value = payload ?? null
    isOpen.value = true
  }

  function close() {
    isOpen.value = false
    data.value = null
  }

  function toggle() {
    isOpen.value = !isOpen.value
  }

  return { isOpen, data, open, close, toggle }
}
