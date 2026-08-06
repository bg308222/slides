<script setup lang="ts">
withDefaults(defineProps<{
  cols: string[]
  rows: string[][]
  title?: string
  dim?: boolean
  /** 視覺規則 A：整張表是加密過的，標題旁掛鎖 */
  locked?: boolean
}>(), { title: 'users 資料表', dim: false, locked: false })
</script>

<template>
  <div class="w-full transition-opacity duration-500" :class="dim ? 'opacity-20' : 'opacity-100'">
    <div class="opacity-50 mb-1 flex items-center gap-1" style="font-size: 10px">
      {{ title }}<Lock v-if="locked" :size="11" />
    </div>
    <table class="w-full font-mono border-collapse" style="font-size: 11px">
      <thead>
        <tr>
          <th
            v-for="c in cols"
            :key="c"
            class="border border-white/15 px-2 py-1 text-left font-normal opacity-55"
          >
            {{ c }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(r, i) in rows" :key="i">
          <td
            v-for="(cell, j) in r"
            :key="j"
            class="border border-white/15 px-2 py-1"
            v-html="cell"
          />
        </tr>
      </tbody>
    </table>
  </div>
</template>
