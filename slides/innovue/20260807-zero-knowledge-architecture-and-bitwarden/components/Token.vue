<script setup lang="ts">
withDefaults(defineProps<{
  label?: string
  value?: string
  note?: string
  variant?: 'plain' | 'hash' | 'key' | 'locked' | 'data' | 'seed'
  dim?: boolean
}>(), { variant: 'plain', dim: false })

const styles: Record<string, string> = {
  plain:  'border-red-400/70   bg-red-400/10   text-red-300',
  hash:   'border-amber-400/70 bg-amber-400/10 text-amber-300',
  key:    'border-teal-400/70  bg-teal-400/10  text-teal-300',
  locked: 'border-slate-400/60 bg-slate-400/10 text-slate-300',
  data:   'border-sky-400/70   bg-sky-400/10   text-sky-300',
  seed:   'border-violet-400/70 bg-violet-400/10 text-violet-300',
}
</script>

<template>
  <div
    class="inline-flex flex-col items-center gap-1 transition-all duration-500"
    :class="dim ? 'opacity-20' : 'opacity-100'"
  >
    <div v-if="label" class="opacity-60 leading-none" style="font-size: 11px">{{ label }}</div>
    <div
      class="px-3 py-1.5 rounded-md font-mono text-sm border whitespace-nowrap"
      :class="styles[variant]"
    >
      <slot>{{ value }}</slot>
    </div>
    <div
      v-if="note"
      class="opacity-55 leading-tight text-center max-w-44"
      style="font-size: 10px"
      v-html="note"
    />
  </div>
</template>
