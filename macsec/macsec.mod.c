#include <linux/build-salt.h>
#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0xe252aae1, "module_layout" },
	{ 0x60a13e90, "rcu_barrier" },
	{ 0x5730c945, "genl_unregister_family" },
	{ 0x9d0d6206, "unregister_netdevice_notifier" },
	{ 0x6ef0f89a, "rtnl_link_unregister" },
	{ 0x4c5f5643, "genl_register_family" },
	{ 0xe2e450bb, "rtnl_link_register" },
	{ 0xd2da1048, "register_netdevice_notifier" },
	{ 0x7f1e0d5e, "gro_cells_receive" },
	{ 0x612068f9, "netif_rx" },
	{ 0x37999cf2, "__pskb_pull_tail" },
	{ 0x77558e81, "skb_clone" },
	{ 0xee5bdea3, "___pskb_trim" },
	{ 0xe3c07f53, "skb_pull" },
	{ 0x9fdecc31, "unregister_netdevice_many" },
	{ 0x6261a391, "dev_set_mtu" },
	{ 0x31901f80, "netif_stacked_transfer_operstate" },
	{ 0xc59a7c7d, "gro_cells_init" },
	{ 0x9f54ead7, "gro_cells_destroy" },
	{ 0xae6bb395, "netif_carrier_on" },
	{ 0x38e77df0, "dev_uc_unsync" },
	{ 0x1aedd4a4, "dev_mc_unsync" },
	{ 0xc45f7486, "netif_carrier_off" },
	{ 0x7bac4f01, "skb_split" },
	{ 0x51a1a902, "__netdev_alloc_skb" },
	{ 0x3c3fce39, "__local_bh_enable_ip" },
	{ 0x653ce2, "dev_queue_xmit" },
	{ 0x31b9195c, "__local_bh_disable_ip" },
	{ 0xf6a5c8ea, "dev_set_promiscuity" },
	{ 0x2ec5ce96, "dev_set_allmulti" },
	{ 0x63826f7b, "dev_uc_sync" },
	{ 0xb152f436, "dev_mc_sync" },
	{ 0x510549ec, "dev_uc_del" },
	{ 0xfd7db06c, "dev_uc_add" },
	{ 0x94fb418, "ether_setup" },
	{ 0x83acf9dd, "netdev_rx_handler_register" },
	{ 0xbc3c37bd, "netdev_upper_dev_link" },
	{ 0x6594c47b, "dev_get_nest_level" },
	{ 0x776623c5, "register_netdevice" },
	{ 0xadebaf4a, "eth_type_trans" },
	{ 0x7a4497db, "kzfree" },
	{ 0xd745b577, "skb_to_sgvec" },
	{ 0x50b03c47, "sg_init_table" },
	{ 0x960c5db7, "skb_cow_data" },
	{ 0xc4c45a12, "skb_put" },
	{ 0x5f754e5a, "memset" },
	{ 0x99bb8806, "memmove" },
	{ 0x55ed06fb, "skb_push" },
	{ 0xe767983f, "skb_copy" },
	{ 0xd71f73cc, "kfree_skb" },
	{ 0x3a3f591c, "consume_skb" },
	{ 0x85f8c0d9, "skb_copy_expand" },
	{ 0xe2b5e146, "refcount_inc_not_zero_checked" },
	{ 0xa5a44c59, "netdev_rx_handler_unregister" },
	{ 0xbd160972, "netdev_upper_dev_unlink" },
	{ 0xd950b864, "unregister_netdevice_queue" },
	{ 0x16305289, "warn_slowpath_null" },
	{ 0x463743a8, "skb_trim" },
	{ 0x25d446f3, "genlmsg_put" },
	{ 0x9d669763, "memcpy" },
	{ 0x3c8f335f, "nla_put" },
	{ 0xf4a7c48c, "nla_put_64bit" },
	{ 0xcf3fac84, "cpumask_next" },
	{ 0x341dbfa3, "__per_cpu_offset" },
	{ 0x1e96f43d, "__cpu_possible_mask" },
	{ 0x17de3d5, "nr_cpu_ids" },
	{ 0x6c209eab, "__alloc_percpu_gfp" },
	{ 0x8f3625fe, "_raw_spin_unlock_bh" },
	{ 0x2b5ab97d, "_raw_spin_lock_bh" },
	{ 0x50c89f23, "__alloc_percpu" },
	{ 0xc6037696, "kmem_cache_alloc_trace" },
	{ 0xd824428a, "kmalloc_caches" },
	{ 0x3127a8d1, "crypto_aead_setauthsize" },
	{ 0xec96f7dc, "crypto_aead_setkey" },
	{ 0x8e2befdc, "crypto_alloc_aead" },
	{ 0x12da5bb2, "__kmalloc" },
	{ 0x85e74337, "crypto_destroy_tfm" },
	{ 0x37a0cba, "kfree" },
	{ 0xc9ec4e21, "free_percpu" },
	{ 0x28aa6a67, "call_rcu" },
	{ 0xc1e58a5f, "refcount_dec_and_test_checked" },
	{ 0x6e720ff2, "rtnl_unlock" },
	{ 0xc7a4fbed, "rtnl_lock" },
	{ 0xdecd0b29, "__stack_chk_fail" },
	{ 0xf1db1704, "nla_memcpy" },
	{ 0x8f678b07, "__stack_chk_guard" },
	{ 0x5269a1d4, "__dev_get_by_index" },
	{ 0xc78f077, "nla_parse" },
	{ 0xc5850110, "printk" },
	{ 0xdb9ca3c5, "_raw_spin_lock" },
	{ 0xb1ad28e0, "__gnu_mcount_nc" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";


MODULE_INFO(srcversion, "BFA31E8486639037D3999AB");
