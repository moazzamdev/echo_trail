package com.echo_trail

object PhoneNumberUtils {

    /**
     * Normalizes a phone number to a consistent format.
     *
     * @param number The raw phone number string.
     * @return A normalized version of the phone number (e.g., +923001234567).
     */
    fun normalizePhoneNumber(number: String): String {
        // Remove all non-digit characters
        val digitsOnly = number.filter { it.isDigit() }

        if (digitsOnly.isEmpty()) {
            return number // fallback if no digits found
        }

        // Handle common country codes based on your region
        return when {
            digitsOnly.startsWith("92") && digitsOnly.length == 12 -> digitsOnly // already Pakistan (+92) format
            digitsOnly.startsWith("0") && digitsOnly.length == 11 -> "+92${digitsOnly.substring(1)}" // convert 03001234567 → +923001234567
            digitsOnly.length == 10 -> "+92${digitsOnly}" // convert 3001234567 → +923001234567
            else -> "+$digitsOnly" // fallback for other countries
        }
    }
}