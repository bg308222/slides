<script setup lang="ts">
/**
 * 4-2：同一排四格，位置固定。
 * step 0 第一列（第一章 demo 的做法）
 *      1 第二列出現：用 AD 帳號登入 Windows
 *      2 金票在登入 Windows 的那一刻就出現
 *      3 401 那一格不會出現
 *      4 其餘照舊：換藍票、進 app
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })

const cols = ['登入電腦', '開 app 時', '金票從哪來', '之後']
const rowA = ['本機帳號登入 Windows', '跳 401，輸入帳密', '拿這組帳密向 AD 換金票', '換藍票，進 app']
</script>

<template>
  <div class="mx-auto" style="max-width: 900px">
    <div class="grid gap-2" style="grid-template-columns: 100px repeat(4, 1fr)">
      <div />
      <div v-for="c in cols" :key="c" class="text-center text-xs opacity-50 tracking-widest">{{ c }}</div>

      <!-- 沒加入網域 -->
      <div class="flex items-center text-sm opacity-80" style="height: 72px">沒加入網域</div>
      <div v-for="(t, i) in rowA" :key="'a' + i"
           class="flex items-center justify-center text-center rounded-md px-2 text-sm leading-snug"
           style="height: 72px; border: 1px solid #ffffff2a; background: #ffffff08"
           :style="i === 2 ? { borderColor: '#fbbf24aa' } : {}">
        {{ t }}
      </div>

      <!-- 加入網域 -->
      <div class="flex items-center text-sm transition-opacity duration-500" style="height: 72px"
           :class="props.step >= 1 ? 'opacity-90' : 'opacity-0'">加入網域</div>

      <div class="flex items-center justify-center text-center rounded-md px-2 text-sm leading-snug transition-opacity duration-500"
           style="height: 72px; border: 1px solid #ffffff2a; background: #ffffff08"
           :class="props.step >= 1 ? 'opacity-100' : 'opacity-0'">
        用 AD 帳號登入 Windows
      </div>

      <div class="flex items-center justify-center text-center rounded-md px-2 text-sm leading-snug transition-opacity duration-500"
           style="height: 72px; border: 1px dashed #ffffff2a"
           :class="props.step >= 3 ? 'opacity-100' : 'opacity-0'">
        <div class="flex flex-col items-center">
          <span class="line-through opacity-50">跳 401，輸入帳密</span>
          <span class="text-xs mt-1" style="color: #fda4af">不會出現</span>
        </div>
      </div>

      <div class="flex items-center justify-center text-center rounded-md px-2 text-sm leading-snug transition-opacity duration-500"
           style="height: 72px; border: 1px solid #fbbf24aa; background: #fbbf2410"
           :class="props.step >= 2 ? 'opacity-100' : 'opacity-0'">
        登入時就換到金票
      </div>

      <div class="flex items-center justify-center text-center rounded-md px-2 text-sm leading-snug transition-opacity duration-500"
           style="height: 72px; border: 1px solid #ffffff2a; background: #ffffff08"
           :class="props.step >= 4 ? 'opacity-100' : 'opacity-0'">
        換藍票，進 app
      </div>
    </div>
  </div>
</template>
