/**
 * @file application.cpp
 * @author Aleksandr Ivashov (a.ivashov@t-ener.com)
 * @brief
 * This file contains the implementation of the main application module for the compressor inverter system.
 * It initializes and manages the core system components, FreeRTOS tasks, and timers required for system operation.
 *
 * The module includes:
 * - Initialization of the compressor inverter system components.
 * - Creation and management of FreeRTOS tasks and timers.
 * - Integration with logging, monitoring, and control modules.
 * - Implementation of the main application entry point.
 *
 * This module ensures the proper startup and operation of the compressor inverter system.
 *
 * @date 2025-04-18
 * @copyright Copyright AES LLC (c) 2025
 *
 */
#include <cstring>

#include <cstdio>
#include <list>

#include "application.h"
#include "main.h"
#include "stm32h7xx_hal.h"
#include "sdmmc.h"
#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"


static TimerHandle_t timerBlink;

static StaticTimer_t stimerBlink;

static constexpr TickType_t BLINK_TIMER_PERIOD = 500;

void MainTaskFunc(void* pvParameters)
{
	timerBlink = xTimerCreateStatic(
	  "blink", BLINK_TIMER_PERIOD, pdTRUE, 0,
	  [](TimerHandle_t xTimer)
	  {
		  (void)xTimer;
		  LL_GPIO_TogglePin(LED_BLUE_GPIO_Port, LED_BLUE_Pin);

	  },
	  &stimerBlink);
	xTimerStart(timerBlink, portMAX_DELAY);
	if(LL_GPIO_IsInputPinSet(SDMMC1_SW_GPIO_Port, SDMMC1_SW_Pin))
	{
		MX_SDMMC1_SD_Init();
	}
	for(;;){}
}

/**
 * @brief Entry point for the application.
 *
 * This function starts the main task (MainTaskFunc) with the given parameters, and then
 * starts the FreeRTOS scheduler. After the scheduler is started, the function enters an
 * infinite loop, which is required to keep the application running.
 *
 * @details
 * The main task is responsible for initializing the main system components, starting the
 * core FreeRTOS tasks, and initializing the main application timer. It also initializes
 * the compressor inverter system parameters and starts the monitoring and logging tasks.
 */
void Application()
{
	xTaskCreate(MainTaskFunc, "MainTask", 1024, NULL, 1, NULL);
	vTaskStartScheduler();
	while(1)
	{}
}

extern "C" void HardFault_Handler(void)
{
  /* USER CODE BEGIN HardFault_IRQn 0 */

  /* USER CODE END HardFault_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_HardFault_IRQn 0 */
    /* USER CODE END W1_HardFault_IRQn 0 */
  }
}

extern "C" void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName)
{
    __BKPT(0);
}

void vApplicationGetIdleTaskMemory( StaticTask_t **ppxIdleTaskTCBBuffer, uint32_t **ppxIdleTaskStackBuffer, uint32_t *pulIdleTaskStackSize )
{
	static StaticTask_t xIdleTaskTCB;
	static uint32_t uxIdleTaskStack[ configMINIMAL_STACK_SIZE ];

	*ppxIdleTaskTCBBuffer = &xIdleTaskTCB;
	*ppxIdleTaskStackBuffer = uxIdleTaskStack;
	*pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}

void vApplicationGetTimerTaskMemory( StaticTask_t **ppxTimerTaskTCBBuffer, StackType_t **ppxTimerTaskStackBuffer, uint32_t *pulTimerTaskStackSize )
{
	/* If the buffers to be provided to the Timer task are declared inside this
	function then they must be declared static - otherwise they will be allocated on
	the stack and hence would not exists after this function exits. */
	static StaticTask_t xTimerTaskTCB;
	static StackType_t uxTimerTaskStack[ configMINIMAL_STACK_SIZE ];
	/* Pass out a pointer to the StaticTask_t structure in which the Timer task's
	state will be stored. */
	*ppxTimerTaskTCBBuffer = &xTimerTaskTCB;
	/* Pass out the array that will be used as the Timer task's stack. */
	*ppxTimerTaskStackBuffer = uxTimerTaskStack;
	/* Pass out the stack size of the array pointed to by *ppxTimerTaskStackBuffer.
	Note the stack size is a count of StackType_t */
	*pulTimerTaskStackSize = sizeof(uxTimerTaskStack) / sizeof(*uxTimerTaskStack);
}