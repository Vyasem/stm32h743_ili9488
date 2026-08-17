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

//#include "freertos_utils/freertos_utils.h"

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
	if(LL_GPIO_IsInputPinSet(SDMMC1_SW_GPIO_Port, SDMMC1_SW_Pin))
	{
		MX_SDMMC1_SD_Init();
		LL_GPIO_SetOutputPin(LED_BLUE_GPIO_Port, LED_BLUE_Pin);
	}
	while(1)
	{}
}